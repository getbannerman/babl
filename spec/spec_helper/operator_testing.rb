# frozen_string_literal: true
require 'babl'
require 'oj'
require 'json-schema'
require 'spec_helper/schema_utils'

module SpecHelper
    module OperatorTesting
        def template(*args, &block)
            let(:template) { dsl.source(*args, &block) }
        end

        def self.extended(base)
            base.include SchemaUtils

            base.let(:dsl) { Babl::Template.new }
            base.let(:compiled) { template.compile }
            base.let(:unchecked_json) { ::Oj.load(compiled.json(object)) }
            base.let(:dependencies) { compiled.send(:dependencies) }
            base.let(:schema) { compiled.send(:node).schema }
            base.let(:json_schema) { compiled.json_schema }
            base.let(:object) { nil }

            base.let(:json) {
                JSON::Validator.validate!(json_schema, unchecked_json, validate_schema: true)
                unchecked_json
            }

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
