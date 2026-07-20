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

    //TODO: MàJ lib Google ?
    public func create(
        reachFive: ReachFive,
        providerConfig: ProviderConfig,
        clientConfigResponse: ClientConfigResponse
    ) -> Provider {
        ConfiguredGoogleProvider(
            sdkConfig: reachFive.sdkConfig,
            providerConfig: providerConfig,
            reachFiveApi: reachFive.reachFiveApi,
            clientConfigResponse: clientConfigResponse
        )
    }
}

public class ConfiguredGoogleProvider: NSObject, Provider {
    public var name: String = GoogleProvider.NAME

    var sdkConfig: SdkConfig
    var providerConfig: ProviderConfig
    var reachFiveApi: ReachFiveApi
    var clientConfigResponse: ClientConfigResponse

    public init(sdkConfig: SdkConfig, providerConfig: ProviderConfig, reachFiveApi: ReachFiveApi, clientConfigResponse: ClientConfigResponse) {
        self.sdkConfig = sdkConfig
        self.providerConfig = providerConfig
        self.reachFiveApi = reachFiveApi
        self.clientConfigResponse = clientConfigResponse
    }

    public func login(
        scope: [String]?,
        origin: String,
        presenting: Presentation
    ) async throws -> AuthToken {
        let viewController = try await presenting.presentingViewController()

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController, hint: nil, additionalScopes: providerConfig.scope) { result, error in
                Task {
                    guard let result else {
                        let reason = error?.localizedDescription ?? "No user"
                        continuation.resume(throwing: ReachFiveError.AuthFailure(reason: reason))
                        return
                    }

                    let loginProviderRequest = LoginProviderRequest(
                        provider: self.providerConfig.providerWithVariant,
                        providerToken: result.user.accessToken.tokenString,
                        code: nil,
                        origin: origin,
                        clientId: self.sdkConfig.clientId,
                        responseType: "token",
                        scope: scope?.joined(separator: " ") ?? self.clientConfigResponse.scope
                    )
                    continuation.resume {
                        let token = try await self.reachFiveApi.loginWithProvider(loginProviderRequest: loginProviderRequest)
                        return try AuthToken.fromOpenIdTokenResponse(token)
                    }
                }
            }
        }
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
