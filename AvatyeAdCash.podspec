Pod::Spec.new do |s|
  s.name = "AvatyeAdCash"
  s.version = "1.1.4"
  s.summary = "Avatye Advertise support framework"

  s.description = <<-DESC
Support to present Banner and Interstitial type Advertise.
  DESC

  s.homepage = "https://bitbucket.org/sjpark_avatye/sdk-ad-library-ios-src"
  s.license = {:type => "MIT", :file => "LICENSE"}
  s.author = {"LimJaeHyuk" => "lim0202jh@avatye.com"}
  s.source = {:git => "https://github.com/avatye-developer/sdk_adcash_ios.git", :tag => "v" + s.version.to_s}

  s.platform = :ios, "11.0"

  s.swift_versions = "5.0"

  s.resources = "AvatyeAdCash.bundle"
  s.ios.vendored_frameworks = "AvatyeAdCash.xcframework"

  s.static_framework = true

  s.frameworks = "AdSupport", "AppTrackingTransparency"

  s.dependency("AdPopcornSSP", "2.5.3")
end
