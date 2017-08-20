require 'babl/utils'
require 'babl/schema'

module Babl
    module Nodes
        class Typed < Utils::Value.new(:schema)
            BOOLEAN = new(Schema::Typed::BOOLEAN)
            INTEGER = new(Schema::Typed::INTEGER)
            NUMBER = new(Schema::Typed::NUMBER)
            STRING = new(Schema::Typed::STRING)

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def render(ctx)
                value = ctx.object
                return value if schema.classes.any? { |clazz| clazz === value }
                raise Errors::RenderingError, "Expected type '#{schema.type}': #{value}\n#{ctx.formatted_stack}"
            end
        end
    end
end
