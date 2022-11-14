#
# Be sure to run `pod lib lint KetchSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KetchSDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of KetchSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Anton Lyfar/KetchSDK'
  # s.screenshots    = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Lyfar' => 'alyfar@transcenda.com' }
  # s.source         = { :http => "https://ketch.jfrog.io/artifactory/ios/KetchSDK/ketchSDK.tar.gz" }
  s.source           = { :git => 'https://github.com/ketch-sdk/ketch-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.subspec 'Core' do |core|
    core.source_files = 'KetchSDK/Classes/Core/**/*.{swift}'
  end

  s.subspec 'CCPA' do |ccpa|
    ccpa.source_files = 'KetchSDK/Classes/CCPA/**/*.{swift}'
    ccpa.dependency 'KetchSDK/Core'
  end

  s.subspec 'TCF' do |tcf|
    tcf.source_files = 'KetchSDK/Classes/TCF/**/*.{swift}'
    tcf.dependency 'KetchSDK/Core'
  end

  s.subspec 'UI' do |ui|
    ui.source_files = 'KetchSDK/Classes/UI/**/*.{swift}'
    ui.dependency 'KetchSDK/Core'
  end
end
