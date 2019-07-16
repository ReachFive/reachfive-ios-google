import Foundation
import UIKit
import IdentitySdkCore
import GoogleSignIn

public class GoogleProvider: ProviderCreator {
    public static var NAME: String = "google"
    
    public var name: String = NAME
    
    public init() {}
    
    public func create(sdkConfig: SdkConfig, providerConfig: ProviderConfig, reachFiveApi: ReachFiveApi) -> Provider {
        return ConfiguredGoogleProvider(sdkConfig: sdkConfig, providerConfig: providerConfig, reachFiveApi: reachFiveApi)
    }
}

public class ConfiguredGoogleProvider: NSObject, Provider, GIDSignInDelegate, GIDSignInUIDelegate {
    public var name: String = GoogleProvider.NAME
    
    var sdkConfig: SdkConfig
    var providerConfig: ProviderConfig
    var reachFiveApi: ReachFiveApi
    
    var scope: [String] = ReachFive.defaultScope
    var origin: String = ""
    var callback: Callback<AuthToken, ReachFiveError>?
    
    public init(sdkConfig: SdkConfig, providerConfig: ProviderConfig, reachFiveApi: ReachFiveApi) {
        self.sdkConfig = sdkConfig
        self.providerConfig = providerConfig
        self.reachFiveApi = reachFiveApi
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            self.callback?(.failure(.AuthFailure(reason: error.localizedDescription)))
        } else {
            let loginProviderRequest = LoginProviderRequest(
                provider: self.providerConfig.provider,
                providerToken: user.authentication.accessToken,
                code: nil,
                origin: origin,
                clientId: self.sdkConfig.clientId,
                responseType: "token",
                scope: scope.joined(separator: " ")
            )
            self.reachFiveApi.loginWithProvider(loginProviderRequest: loginProviderRequest, callback: { response in
                self.callback?(
                    response.flatMap({ openIdTokenResponse in
                        AuthToken.fromOpenIdTokenResponse(openIdTokenResponse: openIdTokenResponse)
                    })
                )
            })
        }
    }
    
    public func login(scope: [String], origin: String, viewController: UIViewController?, callback: @escaping Callback<AuthToken, ReachFiveError>) {
        self.scope = scope
        self.origin = origin
        self.callback = callback
        GIDSignIn.sharedInstance().clientID = self.providerConfig.clientId
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = viewController as? GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
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
    
    public func logout() {
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    public override var description: String {
        return "Provider: \(name)"
    }
}
