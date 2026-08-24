import Foundation
import UIKit
import Reach5
import GoogleSignIn

public class GoogleProvider: ProviderCreator {
    public static var NAME: String = "google"

    public var name: String = NAME
    public var variant: String?

    public init(variant: String? = nil) {
        self.variant = variant
    }

    public func create(
        reachFive: ReachFive,
        providerConfig: ProviderConfig,
        clientConfigResponse: ClientConfigResponse
    ) -> Provider {
        ConfiguredGoogleProvider(
            reachFive: reachFive,
            providerConfig: providerConfig,
            clientConfigResponse: clientConfigResponse
        )
    }
}

public class ConfiguredGoogleProvider: NSObject, Provider {
    public var name: String = GoogleProvider.NAME

    var providerConfig: ProviderConfig
    var clientConfigResponse: ClientConfigResponse

    /// `weak`: ReachFive retains its providers, a strong reference here would create a
    /// ReachFive ↔ ConfiguredGoogleProvider cycle and the SDK graph would never be deallocated.
    private weak var reachFive: ReachFive?

    public init(reachFive: ReachFive, providerConfig: ProviderConfig, clientConfigResponse: ClientConfigResponse) {
        self.reachFive = reachFive
        self.providerConfig = providerConfig
        self.clientConfigResponse = clientConfigResponse
    }

    public func login(
        scope: [String]?,
        origin: String,
        presenting: Presentation
    ) async throws -> AuthToken {
        // Read before Google's dialog opens, so a deallocated SDK fails the login right away
        // instead of once the user has signed in.
        let reachFive = try requireReachFive()

        let googleAccessToken = try await Self.googleSignIn(presenting: presenting, additionalScopes: providerConfig.scope)

        let loginProviderRequest = LoginProviderRequest(
            provider: providerConfig.providerWithVariant,
            providerToken: googleAccessToken,
            code: nil,
            origin: origin,
            clientId: reachFive.sdkConfig.clientId,
            responseType: "token",
            scope: scope?.joined(separator: " ") ?? clientConfigResponse.scope
        )
        let token = try await reachFive.reachFiveApi.loginWithProvider(loginProviderRequest: loginProviderRequest)
        return try AuthToken.fromOpenIdTokenResponse(token)
    }

    /// Isolated to the main actor because it drives Google's UI: `signIn(withPresenting:)` starts an
    /// `ASWebAuthenticationSession`, which immediately asks AppAuth for a presentation anchor, and that
    /// anchor reads `viewController.view.window`. `login` being a plain async method, without this the
    /// call ran on a cooperative background thread: UIKit off the main thread — unsupported, and
    /// reported by the Main Thread Checker. Same fix as `FacebookProvider.doFacebookLogin`.
    ///
    /// Nothing here blocks the main thread: `signIn` returns as soon as the session is started, and the
    /// ReachFive exchange runs outside this method.
    ///
    /// The continuation only carries Google's access token out of the completion handler: the handler is
    /// `@Sendable`, so anything it captured — the provider itself, the ReachFive instance, Google's own
    /// non-Sendable result — would have to be `Sendable` too. The ReachFive exchange therefore runs in
    /// the caller's task rather than a detached one.
    ///
    /// `static`: an instance method would send the non-Sendable `self` from `login` to the main actor,
    /// which strict concurrency rejects. Everything needed is `Sendable` and passed as a parameter.
    @MainActor
    private static func googleSignIn(presenting: Presentation, additionalScopes: [String]?) async throws -> String {
        let viewController = try presenting.presentingViewController()

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController, hint: nil, additionalScopes: additionalScopes) { result, error in
                guard let result else {
                    let reason = error?.localizedDescription ?? "No user"
                    continuation.resume(throwing: ReachFiveError.AuthFailure(reason: reason))
                    return
                }
                continuation.resume(returning: result.user.accessToken.tokenString)
            }
        }
    }

    private func requireReachFive() throws -> ReachFive {
        guard let reachFive else { throw ReachFiveError.TechnicalError(reason: "ReachFive instance was deallocated") }
        return reachFive
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    public func logout() -> Void {
        GIDSignIn.sharedInstance.signOut()
    }

    public override var description: String {
        "Provider: \(name)"
    }
}
