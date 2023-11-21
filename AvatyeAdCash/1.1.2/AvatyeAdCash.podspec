#
# Be sure to run `pod lib lint AvatyeAdCash.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = "AvatyeAdCash"
  s.version = "1.1.2"
  s.summary = "Avatye Advertise support framework"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description = <<-DESC
Support to present Banner and Interstitial type Advertise.
  DESC

  s.homepage = "https://bitbucket.org/sjpark_avatye/sdk-ad-library-ios-src"
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license = {:type => "MIT", :file => "LICENSE"}
  s.author = {"LimJaeHyuk" => "lim0202jh@avatye.com"}
  s.source = {:git => "https://bitbucket.org/avatye/sdk-ad-library-ios-src.git", :tag => "v" + s.version.to_s}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = "11.0"

  s.swift_versions = "5.0"

  s.source_files = "AvatyeAdCash/Classes/**/*.{m,h,swift}"
  s.resource_bundles = {
    "AvatyeAdCashResource" => ["AvatyeAdCash/Assets/Images.xcassets"]
  }
  # s.resources = ['AvatyeAdCash/Assets/AdCashImages.xcassets']

  s.static_framework = true

  s.frameworks = "AdSupport", "AppTrackingTransparency"

  s.dependency("AdPopcornSSP", "2.5.3")
end
