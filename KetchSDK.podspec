Pod::Spec.new do |s|
  s.name             = 'KetchSDK'
  s.version          = '3.0.0'
  s.summary          = 'Integrated solution for user data usage consents management'
  s.homepage         = 'https://ketch.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Ketch' => 'info@ketch.com' }
  s.source           = { :http => "https://ketch.jfrog.io/artifactory/ios/KetchSDK/ketchSDK.tar.gz" }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/KetchSDK/Core/**/*.{swift}'
  end
  
  s.subspec 'UI' do |ui|
    ui.source_files = 'Sources/KetchSDK/UI/**/*.{swift}'
    ui.resource_bundle = { 'KetchUI' => [
      'Sources/KetchSDK/**/*.{xcassets}',
      'Sources/KetchSDK/**/*.{html}'
      ] }
    ui.dependency 'KetchSDK/Core'
  end
end
