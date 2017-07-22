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

            def renderer(ctx)
                renderers = nodes.map { |node| node.renderer(ctx) }
                Codegen::Expression.new { |resolver|
                    '[' + renderers.map { |expr| resolver.resolve(expr) }.join(',') + ']'
                }
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
