require_relative './version'

Pod::Spec.new do |spec|
  spec.name                  = "IdentitySdkGoogle"
  spec.version               = $VERSION
  spec.summary               = "ReachFive IdentitySdkGoogle"
  spec.description           = <<-DESC
      ReachFive Identity Sdk Google
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

  spec.static_framework = true

  spec.dependency 'IdentitySdkCore'
  spec.dependency 'GoogleSignIn', '~> 7'
end