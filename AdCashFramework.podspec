Pod::Spec.new do |spec|

  spec.name         = "AdCashFramework"
  spec.version      = "3.1.1"
  spec.summary      = "Avatye Advertise support framework"
  spec.description  = <<-DESC
                        Support to present Banner and Interstitial type Advertise.
                        DESC

  spec.homepage     = "https://github.com/avatye-developer/sdk_adcash_ios"
  spec.license      = { :type => "MIT", :text => "Copyright 2024 Avatye Corp." }
  spec.author       = {"LimJaeHyuk" => "lim0202jh@avatye.com"}
  
  spec.ios.deployment_target = "12.0"
  spec.source       = {:git => "https://github.com/avatye-developer/sdk_adcash_ios.git", :tag => "v#{spec.version.to_s}"}

  spec.swift_versions = ["5.0"]

  spec.frameworks   = "AdSupport", "AppTrackingTransparency"

  spec.vendored_frameworks = "SDK/AdCashFramework.xcframework"

  spec.dependency "AdPopcornSSP", "~> 2.7.1"
  
end
