Pod::Spec.new do |spec|
spec.name         = 'WebStruct'
spec.version      = '0.2.2'
spec.license      = { :type => 'MIT' }
spec.homepage     = 'https://github.com/iq3addLi/WebStruct'
spec.authors      = { 'iq3' => 'iq3@addli.co.jp' }
spec.summary      = 'Swift struct initalize from WebAPI'
spec.source       = { :git => 'https://github.com/iq3addLi/WebStruct.git', :tag => '0.2.2' }
spec.source_files = 'Sources/*.swift'

spec.ios.deployment_target = '9.0'
spec.osx.deployment_target = '10.10'

end
