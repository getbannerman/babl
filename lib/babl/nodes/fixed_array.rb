# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class FixedArray < Utils::Value.new(:nodes)
            EMPTY = new(Utils::Array::EMPTY)

            def schema
                Schema::FixedArray.new(nodes.map(&:schema))
            end

            def dependencies
                Babl::Utils::Hash.deep_merge(*nodes.map(&:dependencies))
            end

            def pinned_dependencies
                Babl::Utils::Hash.deep_merge(*nodes.map(&:pinned_dependencies))
            end

            def render(frame)
                nodes.map { |node| node.render(frame) }
            end

            def optimize
                optimized_nodes = nodes.map(&:optimize)
                fixed_array = FixedArray.new(optimized_nodes)
                return fixed_array unless optimized_nodes.all? { |node| Constant === node }
                Constant.new(fixed_array.nodes.map(&:value).freeze, fixed_array.schema)
            end
        end
    end
end
