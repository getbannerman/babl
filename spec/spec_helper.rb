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

            base.before {
                stub_const('TestLookupContext', Class.new {
                    attr_reader :code, :childs

                    def initialize(code = nil, **childs)
                        @code = code
                        @childs = childs
                    end

                    def find(name)
                        name = name.to_sym
                        return unless childs[name]
                        [name.to_s, childs[name].code, childs[name]]
                    end
                })
            }
        end
    end
end
