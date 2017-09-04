# frozen_string_literal: true
require 'babl/utils'
require 'babl/schema'
require 'babl/nodes/terminal_value'

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
                if schema.classes.any? { |clazz| clazz === value }
                    return ::Numeric === value ? TerminalValue.instance.render_object(value) : value
                end
                raise Errors::RenderingError, "Expected type '#{schema.type}': #{value}\n#{ctx.formatted_stack}"
            end

            def optimize
                self
            end
        end
    end
end
