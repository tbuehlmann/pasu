# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pasu/version'

Gem::Specification.new do |spec|
  spec.name          = 'pasu'
  spec.version       = Pasu::VERSION
  spec.authors       = ['Tobias Bühlmann']
  spec.email         = ['tobias.buehlmann@gmx.de']
  spec.summary       = 'Simple File Serving HTTP Server'
  spec.description   = 'Pasu is a simple HTTP Server for serving (and uploading) Files.'
  spec.homepage      = 'https://github.com/tbuehlmann/pasu'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = ['pasu']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency 'cuba', '~> 3.1'
  spec.add_runtime_dependency 'cuba-sendfile', '0.0.2'
  spec.add_runtime_dependency 'slim', '~> 2.0'
  spec.add_runtime_dependency 'tilt', '~> 2.0'
  spec.add_runtime_dependency 'puma', '~> 2.7'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'pry', '0.9.12.6'
end
