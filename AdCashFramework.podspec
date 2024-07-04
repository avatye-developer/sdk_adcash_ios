Pod::Spec.new do |spec|
  spec.name = "AvatyeAdCash"
  spec.version = "3.1.0"
  spec.summary = "Avatye Advertise support framework"

  spec.description = <<-DESC
Support to present Banner and Interstitial type Advertise.
  DESC

  spec.homepage = "https://bitbucket.org/sjpark_avatye/sdk-ad-library-ios-src"
  spec.license = { :type => "MIT", :text => <<-LICENSE
    Copyright (c) 2023 Avatye <sjpark@avatye.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
  }
  spec.author = {"LimJaeHyuk" => "lim0202jh@avatye.com"}
  spec.source = {:http => "https://avatye-ios-sdk.s3.ap-northeast-2.amazonaws.com/adcash/AdCashFramework.xcframework.zip"}

  spec.ios.deployment_target = "12.0"

  spec.swift_versions = ["5.0"]

  spec.frameworks = "AdSupport", "AppTrackingTransparency"

  spec.vendored_frameworks = "AdCashFramework.xcframework"

  spec.dependency "AdPopcornSSP", "~> 2.7.1"
  
end
