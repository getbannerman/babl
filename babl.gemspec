# frozen_string_literal: true
require File.join(File.dirname(__FILE__), 'lib/babl/version')

Gem::Specification.new do |gem|
    gem.name          = "babl-json"
    gem.version       = Babl::VERSION
    gem.licenses      = ['MIT']
    gem.authors       = ['Frederic Terrazzoni']
    gem.email         = ['frederic.terrazzoni@gmail.com']
    gem.description   = "JSON templating on steroids"
    gem.summary       = gem.description
    gem.homepage      = 'https://github.com/getbannerman/babl'

    gem.files         = `git ls-files lib`.split($INPUT_RECORD_SEPARATOR)
    gem.executables   = []
    gem.test_files    = []
    gem.require_paths = ['lib']

    gem.add_development_dependency 'pry', '~> 0'
    gem.add_development_dependency 'rspec', '~> 3'
    gem.add_development_dependency 'rubocop', '~> 0.48'
    gem.add_development_dependency 'json-schema', '~> 2.8'
    gem.add_development_dependency 'coveralls', '~> 0.8'
    gem.add_development_dependency 'jbuilder', '~> 2'

    gem.add_dependency 'multi_json', '~> 1'
end
