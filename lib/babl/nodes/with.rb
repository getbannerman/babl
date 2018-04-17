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
                    node.dependencies[Parent::PARENT_MARKER] || Utils::Hash::EMPTY,
                    nodes.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b|
                        Babl::Utils::Hash.deep_merge(a, b)
                    }
                )
            end

            def pinned_dependencies
                (nodes + [node]).map(&:pinned_dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def render(context, frame)
                values = nodes.map { |n| n.render(context, frame) }
                value = begin
                    block.arity.zero? ? frame.object.instance_exec(&block) : block.call(*values)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + context.formatted_stack(frame, :__block__), e.backtrace
                end

                context.move_forward(frame, value, :__block__) do |new_frame|
                    node.render(context, new_frame)
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
