# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'

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
        end
    end
end
