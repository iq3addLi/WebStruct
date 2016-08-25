Pod::Spec.new do |spec|
spec.name         = 'WebStruct'
spec.version      = '0.1'
spec.license      = { :type => 'MIT' }
spec.homepage     = 'https://github.com/iq3addLi/WebStruct'
spec.authors      = { 'Ikumi Arakane' => 'iq3@addli.co.jp' }
spec.summary      = 'Swift struct initalize from WebAPI'
spec.source       = { :git => 'https://github.com/iq3addLi/WebStruct.git', :tag => '0.1' }
spec.source_files = 'WebStruct/*.swift'

spec.ios.deployment_target = '9.0'
spec.osx.deployment_target = '10.10'

end