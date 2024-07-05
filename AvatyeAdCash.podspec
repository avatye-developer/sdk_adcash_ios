Pod::Spec.new do |spec|

  spec.name         = "AvatyeAdCash"
  spec.version      = "3.1.4"
  spec.summary      = "Avatye AdCash support framework"
  spec.description  = <<-DESC
                        Support to present Banner and Interstitial type Advertise.
                        DESC

  spec.homepage     = "https://github.com/avatye-developer/sdk_adcash_ios"
  spec.license      = { :type => "MIT", :text => "Copyright (c) 2024 Avatye Corp." }
  spec.author       = {"LimJaeHyuk" => "lim0202jh@avatye.com"}

  spec.ios.deployment_target = "12.0"
  spec.source       = { :git => "https://github.com/avatye-developer/sdk_adcash_ios.git", :tag => "v"+spec.version.to_s }

  spec.swift_versions = ["5.0"]

  spec.frameworks = "AdSupport", "AppTrackingTransparency"

  spec.vendored_frameworks = "AvatyeAdCash.xcframework"

  spec.dependency "AdPopcornSSP", "~> 2.7.1"
  
end
