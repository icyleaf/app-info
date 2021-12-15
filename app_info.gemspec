# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_info/version'

Gem::Specification.new do |spec|
  spec.name          = 'app-info'
  spec.version       = AppInfo::VERSION
  spec.authors       = ['icyleaf']
  spec.email         = ['icyleaf.cn@gmail.com']

  spec.summary       = 'Teardown tool for mobile app(ipa/apk) and dSYM file, analysis metedata like version, name, icon'
  spec.description   = 'Teardown tool for ipa/apk files and dSYM file, even support for info.plist and .mobileprovision files'
  spec.homepage      = 'http://github.com/icyleaf/app-info'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'CFPropertyList', '< 3.1.0', '>= 2.3.4'
  spec.add_dependency 'image_size', '>= 1.5', '< 3.1'
  spec.add_dependency 'ruby-macho', '< 3', '>= 1.4'
  spec.add_dependency 'android_parser', '~> 2.4.1'
  spec.add_dependency 'rubyzip', '>= 1.2', '< 3.0'
  spec.add_dependency 'uuidtools', '>= 2.1.5', '< 2.3.0'
  spec.add_dependency 'icns', '~> 0.2.0'
  spec.add_dependency 'google-protobuf', '~> 3.18.0'

  spec.add_development_dependency 'bundler', '>= 1.12'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.19'
end
