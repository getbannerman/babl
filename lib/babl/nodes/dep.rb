# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Nodes
        class Dep < Utils::Value.new(:node, :path)
            def render(ctx)
                node.render(ctx)
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def dependencies
                Babl::Utils::Hash.deep_merge(node.dependencies, path)
            end

            def optimize
                Dep.new(node.optimize, path)
            end
        end
    end
end
