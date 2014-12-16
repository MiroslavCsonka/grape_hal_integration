# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape_hal_integration/version'

Gem::Specification.new do |spec|
  spec.name          = 'grape_hal_integration'
  spec.version       = GrapeHalIntegration::VERSION
  spec.authors       = ['Miroslav Csonka']
  spec.email         = ['miroslav.csonka@gmail.com']
  spec.summary       = %q{Provides convenient helpers for using hal with grape framework}
  spec.description   = %q{Automatically generates links between endpoints, help with referencing to endpoint, endpoints can be invoked by any code, autoloads resources}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  
end
