# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_info/version'

Gem::Specification.new do |spec|
  spec.name          = 'app-info'
  spec.version       = AppInfo::VERSION
  spec.authors       = ['icyleaf']
  spec.email         = ['icyleaf.cn@gmail.com']

  spec.summary       = 'Teardown tool for mobile app(ipa/apk), analysis metedata like version, name, icon'
  spec.description   = 'Teardown tool for ipa/apk files, even support for info.plist and .mobileprovision files'
  spec.homepage      = 'http://github.com/icyleaf/app-info'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'CFPropertyList', '~> 2.3.4'
  spec.add_dependency 'pngdefry', '~> 0.1.2'
  spec.add_dependency 'ruby_android', '~> 0.7.7'
  spec.add_dependency 'image_size', '~> 1.5.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
