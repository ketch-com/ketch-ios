Pod::Spec.new do |s|  
    s.name              = 'Ketch'
    s.version           = '1.0.0'
    s.summary           = 'Mobile SDK for Switch-bit'
    s.homepage          = 'https://switchbit.com/'

    s.author            = { 'Name' => 'aleksey@switchbit.com' }
    s.license           = { :type => 'Apache-2.0' }

    s.platform          = :ios
    s.source            = { :source => 'https://switchbit.com/' }

    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = 'Framework/Ketch.framework'
end  