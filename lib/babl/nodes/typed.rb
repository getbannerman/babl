require 'values'
require 'babl/schema/typed'

module Babl
    module Nodes
        class Typed < ::Value.new(:schema, :node)
            CURRIED = method(:new).curry(2)

            BOOLEAN = CURRIED.call(Schema::Typed::BOOLEAN)
            INTEGER = CURRIED.call(Schema::Typed::INTEGER)
            NUMBER = CURRIED.call(Schema::Typed::NUMBER)
            STRING = CURRIED.call(Schema::Typed::STRING)

            def dependencies
                node.dependencies
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(ctx)
                value = node.render(ctx)
                return value if schema.classes.any? { |clazz| clazz === value }
                raise Errors::RenderingError, "Expected type '#{schema.type}': #{value}\n#{ctx.formatted_stack}"
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
