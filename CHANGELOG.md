# Changelog

## v7.1.0
### New features
- Support choosing a variant

## v7.0.0
### Breaking changes
- New name for the Pod: `Reach5Google`

Change all your import from 
```
import IdentitySdkGoogle
```
to
```
import Reach5Google
```

### New features
- Support for Swift Package Manager
- Add privacy manifest.

## v6.0.0

Warning: There are Breaking Changes

### Breaking changes
- Add a new method in `Provider` and `ReachFive`: `application(_:continue:restorationHandler:)` to handle universal links
- Remove an obsolete method in `Provider` and `ReachFive`: `application(_:open:sourceApplication:annotation:)`
- New required property `GIDClientID` in property list to use Google SignIn

### Dependencies
- Updated dependency `GoogleSignIn` from 6 to 7

## v5.7.1
- Update dependency `GoogleSignIn` from 6.2.2 to 6.2.4

## v5.7.0

Warning: There are Breaking Changes

### Breaking changes
- The SDK mandates a minimum version of iOS 13
- New method `Provider.application(_:didFinishLaunchingWithOptions:)` to call at startup to initialize the social providers
- Parameter `viewController` in `Provider.login(scope:origin:viewController:)` is now mandatory
- Some error messages may have changed

### Other changes
- Update dependency `GoogleSignIn` from 5.0.2 to 6.2.2

## v5.5.1
- Upgrade dependency `GoogleSignIn` to version 5.0.2

## v5.2.2
- Fix login with web provider issue (assert() raising a fatal error)

## v5.2.0
### Breaking changes
- `RequestErrors` is renamed to `ApiError`
- `ReachFiveError.AuthFailure` contain an optional parameter of type `ApiError`

## v5.1.0
### Breaking changes
- The login with provider requires now the `scope` parameter `login(scope: [String]?, origin: String, viewController: UIViewController?).`

## v5.0.0

- Use [Futures](https://github.com/Thomvis/BrightFutures) instead of callbacks, we use the [BrightFutures](https://github.com/Thomvis/BrightFutures) library

### Breaking changes
We use Future instead callbacks, you need to transform yours callbacks into the Future
```swift
AppDelegate.reachfive()
  .loginWithPassword(username: email, password: password)
  .onSuccess { authToken in
    // Handle success
  }
  .onFailure { error in
    // Handle error
  }
```

instead of

```swift
AppDelegate.reachfive()
  .loginWithPassword(
    username: email,
    password: password,
    callback: { response in
        switch response {
          case .success(let authToken):
            // Handle success
          case .failure(let error):
            // handle error
          }
    }
)
```


## v4.0.0

### 9th July 2019

### Changes

New modular version of the Identity SDK iOS:

- [`IdentitySdkCore`](IdentitySdkCore)
- [`IdentitySdkFacebook`](IdentitySdkFacebook)
- [`IdentitySdkGoogle`](IdentitySdkGoogle)
- [`IdentitySdkWebView`](IdentitySdkWebView)
