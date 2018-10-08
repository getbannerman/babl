# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class FixedArray < Utils::Value.new(:nodes)
            EMPTY = new(Utils::Array::EMPTY)

            memoize def schema
                Schema::FixedArray.new(nodes.map(&:schema))
            end

            memoize def dependencies
                Babl::Utils::Hash.deep_merge(nodes.map(&:dependencies))
            end

            memoize def pinned_dependencies
                Babl::Utils::Hash.deep_merge(nodes.map(&:pinned_dependencies))
            end

            memoize def optimize
                optimized_nodes = nodes.map(&:optimize)

                fixed_array = self if optimized_nodes.each_with_index.all? { |v, idx| v.equal?(nodes[idx]) }
                fixed_array ||= FixedArray.new(optimized_nodes)

                if optimized_nodes.all? { |node| Constant === node }
                    Constant.new(optimized_nodes.map(&:value).freeze, fixed_array.schema)
                else
                    fixed_array
                end
            end

            def render(frame)
                nodes.map { |node| node.render(frame) }
            end
        end
    end
end
