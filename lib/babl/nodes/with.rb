# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class With < Utils::Value.new(:node, :nodes, :block)
            memoize def schema
                node.schema
            end

            memoize def dependencies
                Babl::Utils::Hash.deep_merge(
                    *nodes.map(&:dependencies),
                    node.dependencies[Parent::PARENT_MARKER] || Utils::Hash::EMPTY
                )
            end

            memoize def pinned_dependencies
                Babl::Utils::Hash.deep_merge(*(nodes + [node]).map(&:pinned_dependencies))
            end

            memoize def optimize
                optimized = node.optimize
                return optimized if Constant === optimized || GotoPin === optimized
                return optimized.node if Parent === optimized
                return self if nodes.empty?

                optimized_nodes = nodes.map(&:optimize)

                if optimized_nodes.all? { |n| Constant === n }
                    value = begin
                        block.call(*optimized_nodes.map(&:value))
                    rescue StandardError => e
                        raise Errors::InvalidTemplate, e.message, e.backtrace
                    end
                    constant_block = Utils::Proc.constant(value)
                    return With.new(optimized, Utils::Array::EMPTY, constant_block)
                end

                return self if optimized.equal?(node) && optimized_nodes.each_with_index.all? { |n, idx| n.equal?(nodes[idx]) }
                With.new(optimized, optimized_nodes, block)
            end

            def render(frame)
                values = nodes.map { |n| n.render(frame) }

                value = begin
                    block.call(*values)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + frame.formatted_stack(:__block__), e.backtrace
                end

                frame.move_forward(value, :__block__) do |new_frame|
                    node.render(new_frame)
                end
            end
        end
    end
end
