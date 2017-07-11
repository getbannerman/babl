require 'babl/utils/hash'
require 'babl/schema/fixed_array'
require 'values'

module Babl
    module Nodes
        class FixedArray < Value.new(:nodes)
            def schema
                Schema::FixedArray.new(nodes.map(&:schema), false)
            end

            def dependencies
                nodes.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def render(ctx)
                nodes.map { |node| node.render(ctx) }
            end
        end
    end
end
