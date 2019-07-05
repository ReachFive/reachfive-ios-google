Pod::Spec.new do |spec|
  spec.name                  = "IdentitySdkGoogle"
  spec.version               = "4.0.0"
  spec.summary               = "ReachFive IdentitySdkGoogle"
  spec.description           = <<-DESC
      ReachFive Identity Sdk Google
  DESC
  spec.homepage              = "https://github.com/ReachFive/identity-ios-sdk"
  spec.license               = { :type => "MIT", :file => "LICENSE" }
  spec.author                = "ReachFive"
  spec.authors               = { "egor" => "egor@reach5.co" }
  spec.swift_versions        = ["5"]
  spec.source                = { :git => "https://github.com/ReachFive/identity-ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files          = "IdentitySdkGoogle/Classes/**/*.*"
  spec.platform              = :ios
  spec.ios.deployment_target = '12.2'

  spec.static_framework = true

  spec.dependency 'IdentitySdkCore', '~> 4.0'
  spec.dependency 'GoogleSignIn', '~> 4.4'
end
