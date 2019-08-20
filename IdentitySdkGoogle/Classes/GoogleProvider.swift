import Foundation
import UIKit
import IdentitySdkCore
import GoogleSignIn
import BrightFutures

public class GoogleProvider: ProviderCreator {
    public static var NAME: String = "google"
    
    public var name: String = NAME
    
    public init() {}
    
    public func create(
        sdkConfig: SdkConfig,
        providerConfig: ProviderConfig,
        reachFiveApi: ReachFiveApi,
        clientConfigResponse: ClientConfigResponse
    ) -> Provider {
        return ConfiguredGoogleProvider(
            sdkConfig: sdkConfig,
            providerConfig: providerConfig,
            reachFiveApi: reachFiveApi,
            clientConfigResponse: clientConfigResponse
        )
    }
}

public class ConfiguredGoogleProvider: NSObject, Provider, GIDSignInDelegate, GIDSignInUIDelegate {
    public var name: String = GoogleProvider.NAME
    
    var sdkConfig: SdkConfig
    var providerConfig: ProviderConfig
    var reachFiveApi: ReachFiveApi
    var clientConfigResponse: ClientConfigResponse
    
    var scope: [String]? = []
    var origin: String = ""
    var promise: Promise<AuthToken, ReachFiveError>?
    
    public init(sdkConfig: SdkConfig, providerConfig: ProviderConfig, reachFiveApi: ReachFiveApi, clientConfigResponse: ClientConfigResponse) {
        self.sdkConfig = sdkConfig
        self.providerConfig = providerConfig
        self.reachFiveApi = reachFiveApi
        self.clientConfigResponse = clientConfigResponse
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            self.promise?.failure(.AuthFailure(reason: error.localizedDescription))
        } else {
            let loginProviderRequest = LoginProviderRequest(
                provider: self.providerConfig.provider,
                providerToken: user.authentication.accessToken,
                code: nil,
                origin: origin,
                clientId: self.sdkConfig.clientId,
                responseType: "token",
                scope: scope != nil ? scope!.joined(separator: " ") : self.clientConfigResponse.scope
            )
            self.reachFiveApi
                .loginWithProvider(loginProviderRequest: loginProviderRequest)
                .flatMap({ AuthToken.fromOpenIdTokenResponseFuture($0) })
                .onSuccess { authToken in
                    self.promise?.success(authToken)
                }
                .onFailure { error in
                    self.promise?.failure(error)
                }
        }
    }
    
    public func login(
        scope: [String]?,
        origin: String,
        viewController: UIViewController?
    ) -> Future<AuthToken, ReachFiveError> {
        self.scope = scope
        self.origin = origin
        let promise = Promise<AuthToken, ReachFiveError>()
        self.promise = promise
        GIDSignIn.sharedInstance().clientID = self.providerConfig.clientId
        GIDSignIn.sharedInstance().scopes = self.providerConfig.scope
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = viewController as? GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
        return promise.future
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var _: [String: AnyObject] = [
            UIApplication.OpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
            UIApplication.OpenURLOptionsKey.annotation.rawValue: annotation as AnyObject
        ]
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {}
    
    public func logout() -> Future<(), ReachFiveError> {
        GIDSignIn.sharedInstance()?.signOut()
        return Future.init(value: ())
    }
    
    public override var description: String {
        return "Provider: \(name)"
    }
}
