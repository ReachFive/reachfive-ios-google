<p align="center">
 <img src="https://www.reachfive.com/hubfs/5399904/Logo-ReachFive.svg" alt="Reach5 Logo" width="700" height="192"/>
</p>

[![CircleCI](https://circleci.com/gh/ReachFive/reachfive-ios-google/tree/master.svg?style=svg)](https://circleci.com/gh/ReachFive/reachfive-ios-google/tree/master)
[![Download](https://img.shields.io/cocoapods/v/IdentitySdkGoogle.svg?style=flat) ](https://cocoapods.org/pods/IdentitySdkGoogle)

# ReachFive Identity iOS SDK for Google Login

## Installation

### Cocoapods

Add the following line to your **Podfile**:

```
pod 'IdentitySdkGoogle'
```

### Swift Package Manager
Open the following menu item in Xcode:

**File > Add Package Dependencies...**

In the **Search or Enter Package URL** search box enter this URL:

https://github.com/ReachFive/reachfive-ios-google.git

Then, select the dependency rule and press **Add Package**.

Or directly add it to the dependencies value of your Package.swift or the Package list in Xcode

```swift
dependencies: [
    .package(url: "https://github.com/ReachFive/reachfive-ios-google.git", .upToNextMajor(from: "6.4.0"))
]
```

## Usage
Refer to the [public documentation](https://developer.reachfive.com/sdk-ios/index.html) to install the SDKs and to initialize your ReachFive client.

The basics are:

- Configuration:

```swift
let reachfive: ReachFive = ReachFive(sdkConfig: sdkConfig, providersCreators: [GoogleProvider()])
```

- Initialisation:

Call this method (that makes a network call) inside the corresponding method of `UIApplicationDelegate`

```swift
reachfive.application(application, didFinishLaunchingWithOptions: launchOptions)
```


## Documentation

You'll find the documentation of the methods exposed on https://developer.reachfive.com/sdk-ios/index.html.

## Changelog

Please refer to [changelog](CHANGELOG.md) to see the descriptions of each release.

## License

[MIT](LICENSE) © [ReachFive](https://reachfive.co/)