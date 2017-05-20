require 'babl'
require 'oj'

module SpecHelper
    module Operators
        def self.included(base)
            base.let(:dsl) { ::Babl::Template.new }
            base.let(:compiled) { template.compile }
            base.let(:json) { ::Oj.load(compiled.json(object)) }
            base.let(:dependencies) { compiled.dependencies }
            base.let(:documentation) { compiled.documentation }
        end
    end
end
