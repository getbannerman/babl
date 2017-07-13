require 'values'
require 'babl/schema/typed'

module Babl
    module Nodes
        class Typed < ::Value.new(:types, :schema, :node)
            BOOLEAN = method(:new).curry(3).call([TrueClass, FalseClass], Schema::Typed::BOOLEAN)
            INTEGER = method(:new).curry(3).call([Integer], Schema::Typed::INTEGER)
            NUMBER = method(:new).curry(3).call([Numeric], Schema::Typed::NUMBER)
            STRING = method(:new).curry(3).call([String], Schema::Typed::STRING)

            def dependencies
                node.dependencies
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(ctx)
                value = node.render(ctx)
                unless types.any? { |type| type === value }
                    raise Errors::RenderingError, "Expected type '#{schema.type}': #{value}\n#{ctx.formatted_stack}"
                end
                value
            end

            private

            def initialize(*)
                super
                check_type_compatibility
            end

            def check_type_compatibility
                return if schema == node.schema
                return if node.schema == Schema::Anything.instance
                raise Errors::InvalidTemplate, "Type cannot be '#{schema.type}' in this context"
            end
        end
    end
end
