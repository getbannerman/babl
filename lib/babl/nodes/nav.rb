# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class Nav < Utils::Value.new(:through, :node)
            def dependencies
                { through => node.dependencies }
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(ctx)
                value = begin
                    ::Hash === ctx.object ? ctx.object.fetch(through) : ctx.object.send(through)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + ctx.formatted_stack(through), e.backtrace
                end
                node.render(ctx.move_forward(value, through))
            end

            def simplify
                simplified = node.simplify
                Constant === simplified ? simplified : Nav.new(through, simplified)
            end
        end
    end
end
