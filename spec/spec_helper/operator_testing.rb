# frozen_string_literal: true
require 'babl'
require 'multi_json'
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
            base.let(:unoptimized_compiled) { template.compile(optimize: false) }
            base.let(:unchecked_json) { ::MultiJson.load(compiled.json(object)) }
            base.let(:unoptimized_unchecked_json) { ::MultiJson.load(unoptimized_compiled.json(object)) }
            base.let(:dependencies) {
                deps = compiled.send(:dependencies)
                expect(Babl::Utils::Hash.deep_merge(deps, unoptimized_dependencies)).to eq unoptimized_dependencies
                deps
            }
            base.let(:unoptimized_dependencies) { unoptimized_compiled.send(:dependencies) }
            base.let(:schema) { compiled.send(:node).schema }
            base.let(:unoptimized_schema) { unoptimized_compiled.send(:node).schema }
            base.let(:json_schema) { compiled.json_schema }
            base.let(:unoptimized_json_schema) { unoptimized_compiled.json_schema }

            base.let(:object) { nil }

            base.let(:json) {
                JSON::Validator.validate!(json_schema, unchecked_json, validate_schema: true)
                JSON::Validator.validate!(unoptimized_json_schema, unchecked_json, validate_schema: true)
                begin
                    expect(unchecked_json).to eq unoptimized_unchecked_json
                rescue Babl::Errors::RenderingError
                    # It happens if the optimization removes navigation that would have failed given input data
                    nil
                end
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
