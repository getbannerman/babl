require 'babl/utils/hash'
require 'values'

module Babl
    module Nodes
        class CreatePin < ::Value.new(:node, :ref)
            def render(ctx)
                node.render(ctx.create_pin(ref))
            end

            def schema
                node.schema
            end

            def dependencies
                Babl::Utils::Hash.deep_merge(node.dependencies, node.pinned_dependencies[ref] || {})
            end

            def pinned_dependencies
                node.pinned_dependencies.reject { |k, _v| k == ref }
            end
        end
    end
end
