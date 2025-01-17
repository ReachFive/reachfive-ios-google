import Foundation
import UIKit
import Reach5
import GoogleSignIn
import BrightFutures

public class GoogleProvider: ProviderCreator {
    public static var NAME: String = "google"

    public var name: String = NAME
    public var variant: String?

    public init(variant: String? = nil) {
        self.variant = variant
    }

    public func create(
        sdkConfig: SdkConfig,
        providerConfig: ProviderConfig,
        reachFiveApi: ReachFiveApi,
        clientConfigResponse: ClientConfigResponse
    ) -> Provider {
        ConfiguredGoogleProvider(
            sdkConfig: sdkConfig,
            providerConfig: providerConfig,
            reachFiveApi: reachFiveApi,
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
        viewController: UIViewController?
    ) -> Future<AuthToken, ReachFiveError> {
        guard let viewController else {
            return Future(error: .TechnicalError(reason: "No presenting viewController"))
        }

        let promise = Promise<AuthToken, ReachFiveError>()
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController, hint: nil, additionalScopes: providerConfig.scope) { result, error in
            guard let result else {
                let reason = error?.localizedDescription ?? "No user"
                promise.failure(.AuthFailure(reason: reason))
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
            promise.completeWith(
                self.reachFiveApi
                    .loginWithProvider(loginProviderRequest: loginProviderRequest)
                    .flatMap({ AuthToken.fromOpenIdTokenResponseFuture($0) })
            )
        }
        return promise.future
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {}

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        true
    }

    public func logout() -> Future<(), ReachFiveError> {
        GIDSignIn.sharedInstance.signOut()
        return Future(value: ())
    }

    public override var description: String {
        "Provider: \(name)"
    }
}
