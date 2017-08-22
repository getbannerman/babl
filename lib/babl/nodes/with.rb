# frozen_string_literal: true
require 'babl/utils'

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
                node.render(ctx.move_forward_block(:__block__) do
                    block.arity.zero? ? ctx.object.instance_exec(&block) : block.call(*values)
                end)
            end
        end
    end
end
