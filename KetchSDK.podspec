#
# Be sure to run `pod lib lint KetchSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KetchSDK'
  s.version          = '4.0.1'
  s.summary          = 'Ketch iOS SDK'
  s.swift_versions   = '5.7'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  The Ketch iOS SDK. See https://developers.ketch.com/docs/ketch-sdk-for-ios-v20 for more info.
                       DESC

  s.homepage         = 'https://github.com/ketch-com/ketch-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Justin Boileau' => 'justin.boileau@ketch.com' }
  s.source           = { :git => 'https://github.com/ketch-com/ketch-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'

  # s.source_files = 'Sources/KetchSDK/**/*'
  s.source_files = 'Sources/KetchSDK/**/*.{h,m,swift}'
  
  # s.resource_bundles = {
  #   'KetchSDK' => ['KetchSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

