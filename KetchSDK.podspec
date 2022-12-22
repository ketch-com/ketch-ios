Pod::Spec.new do |s|
  s.name             = 'KetchSDK'
  s.version          = '0.1.2'
  s.summary          = 'Integrated solution for user data usage consents management'
  s.homepage         = 'https://ketch.com'
  s.author           = { 'Anton Lyfar' => 'alyfar@transcenda.com' }
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.source           = { :http => "https://ketch.jfrog.io/artifactory/ios/KetchSDK/ketchSDK.tar.gz" }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/KetchSDK/Core/**/*.{swift}'
  end

  s.subspec 'CCPA' do |ccpa|
    ccpa.source_files = 'Sources/KetchSDK/CCPA/**/*.{swift}'
    ccpa.dependency 'KetchSDK/Core'
  end

  s.subspec 'TCF' do |tcf|
    tcf.source_files = 'Sources/KetchSDK/TCF/**/*.{swift}'
    tcf.dependency 'KetchSDK/Core'
  end

  s.subspec 'UI' do |ui|
    ui.source_files = 'Sources/KetchSDK/UI/**/*.{swift}'
    ui.resource_bundle = { 'KetchUI' => ['Sources/KetchSDK/**/*.{xcassets}'] }
    ui.dependency 'KetchSDK/Core'
  end
end
