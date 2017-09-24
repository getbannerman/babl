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

            def optimize
                optimized_nodes = nodes.map(&:optimize)
                fixed_array = FixedArray.new(optimized_nodes)
                return fixed_array unless optimized_nodes.all? { |node| Constant === node }
                Constant.new(fixed_array.render(nil).freeze, fixed_array.schema)
            end
        end
    end
end
