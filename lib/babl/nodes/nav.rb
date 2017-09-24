# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'
require 'babl/nodes/parent'

module Babl
    module Nodes
        class Nav < Utils::Value.new(:property, :node)
            def dependencies
                { property => node.dependencies }
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(ctx)
                value = begin
                    ::Hash === ctx.object ? ctx.object.fetch(property) : ctx.object.send(property)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + ctx.formatted_stack(property), e.backtrace
                end
                node.render(ctx.move_forward(value, property))
            end

            def optimize
                optimized = node.optimize
                return optimized if Constant === optimized
                return optimized.node if Parent === optimized
                Nav.new(property, optimized)
            end
        end
    end
end
