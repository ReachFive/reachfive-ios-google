require_relative './version'

Pod::Spec.new do |spec|
  spec.name                  = "Reach5Google"
  spec.version               = $VERSION
  spec.summary               = "Reachfive Identity SDK for Google Login"
  spec.description           = <<-DESC
      Reachfive Identity SDK for iOS integrating with Google Login
  DESC
  spec.homepage              = "https://github.com/ReachFive/reachfive-ios-google"
  spec.license               = { :type => "MIT", :file => "LICENSE" }
  spec.author                = "ReachFive"
  spec.authors               = { "François" => "francois.devemy@reach5.co", "Pierre" => "pierre.bar@reach5.co" }
  spec.swift_versions        = ["5"]
  spec.source                = { :git => "https://github.com/ReachFive/reachfive-ios-google.git", :tag => "#{spec.version}" }
  spec.source_files          = "IdentitySdkGoogle/Classes/**/*.*"
  spec.platform              = :ios
  spec.ios.deployment_target = $IOS_DEPLOYMENT_TARGET
  spec.resource_bundle = {
    'Reach5' => ['IdentitySdkGoogle/PrivacyInfo.xcprivacy']
  }

  spec.static_framework = true

  spec.dependency 'Reach5', :git => 'https://github.com/ReachFive/reachfive-ios.git', :branch => '7.0.0'
  spec.dependency 'GoogleSignIn', '~> 7'
end
