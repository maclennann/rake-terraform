# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake-terraform/version'

Gem::Specification.new do |spec|
  spec.name          = 'rake-terraform'
  spec.version       = RakeTerraform::VERSION
  spec.authors       = ['Norm MacLennan']
  spec.email         = ['norm.maclennan@gmail.com']
  spec.summary       = 'Rake tasks for use with Terraform.'
  spec.description   = 'A collection of rake tasks that can
                        be used to plan, apply, and manage
                        configurations for Hashicorp Terraform.'

  spec.homepage      = 'https://github.com/maclennann/rake-terraform'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)\/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rubocop', '~> 0.29'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_dependency 'rake', '~> 10.0'
  spec.add_dependency 'map', '~> 6.5'
  spec.add_runtime_dependency 'highline', '~> 1.7'
  spec.add_runtime_dependency 'iniparse', '~> 1.3'
end
