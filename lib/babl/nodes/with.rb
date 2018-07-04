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
                Babl::Utils::Hash.deep_merge(
                    *nodes.map(&:dependencies),
                    node.dependencies[Parent::PARENT_MARKER] || Utils::Hash::EMPTY
                )
            end

            def pinned_dependencies
                Babl::Utils::Hash.deep_merge(*(nodes + [node]).map(&:pinned_dependencies))
            end

            def render(frame)
                values = nodes.map { |n| n.render(frame) }
                value = begin
                    block.arity.zero? ? frame.object.instance_exec(&block) : block.call(*values)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + frame.formatted_stack(:__block__), e.backtrace
                end

                frame.move_forward(value, :__block__) do |new_frame|
                    node.render(new_frame)
                end
            end

            def optimize
                optimized = node.optimize
                return optimized if Constant === optimized
                return optimized.node if Parent === optimized
                With.new(optimized, nodes.map(&:optimize), block)
            end
        end
    end
end
