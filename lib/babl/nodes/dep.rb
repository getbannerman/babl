# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Nodes
        class Dep < Utils::Value.new(:node, :path)
            def render(frame)
                node.render(frame)
            end

            memoize def schema
                node.schema
            end

            memoize def pinned_dependencies
                node.pinned_dependencies
            end

            memoize def dependencies
                Babl::Utils::Hash.deep_merge(node.dependencies, path)
            end

            memoize def optimize
                optimized = node.optimize
                optimized.equal?(node) ? self : Dep.new(optimized, path)
            end
        end
    end
end
