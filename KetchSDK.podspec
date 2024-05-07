Pod::Spec.new do |s|
  s.name             = 'KetchSDK'
  s.version          = '4.0.4'
  s.summary          = 'Ketch iOS SDK'
  s.swift_versions   = '5.7'

  s.description      = <<-DESC
  The Ketch iOS SDK. See https://developers.ketch.com/docs/ketch-sdk-for-ios-v20 for more info.
                       DESC

  s.homepage         = 'https://github.com/ketch-com/ketch-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Justin Boileau' => 'justin.boileau@ketch.com' }
  s.source           = { :git => 'https://github.com/ketch-com/ketch-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'

  s.source_files = 'Sources/KetchSDK/**/*.{h,m,swift,html}'
  s.resources = 'Sources/KetchSDK/**/*.html'

end
