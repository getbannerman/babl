# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class FixedArray < Utils::Value.new(:nodes)
            def schema
                Schema::FixedArray.new(nodes.map(&:schema))
            end

            def dependencies
                nodes.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.map(&:pinned_dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def render(ctx)
                nodes.map { |node| node.render(ctx) }
            end

            def simplify
                simplify_constant || simplify_items || self
            end

            private

            def simplify_constant
                Constant.new(render(nil), schema) if nodes.all? { |node| Constant === node }
            end

            def simplify_items
                simplified_nodes = nodes.map(&:simplify)
                FixedArray.new(simplified_nodes).simplify unless simplified_nodes == nodes
            end
        end
    end
end
