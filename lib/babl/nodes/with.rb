# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class With < Utils::Value.new(:node, :nodes, :block)
            def schema
                node.schema
            end

            def dependencies
                # Dependencies of 'node' are explicitely ignored
                nodes.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                (nodes + [node]).map(&:pinned_dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def render(ctx)
                values = nodes.map { |n| n.render(ctx) }
                value = begin
                    block.arity.zero? ? ctx.object.instance_exec(&block) : block.call(*values)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + ctx.formatted_stack(:__block__), e.backtrace
                end
                node.render(ctx.move_forward(value, :__block__))
            end

            def optimize
                optimized = node.optimize
                return optimized if Constant === optimized
                With.new(optimized, nodes.map(&:optimize), block)
            end
        end
    end
end
