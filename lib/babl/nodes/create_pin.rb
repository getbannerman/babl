require 'babl/utils/hash'
require 'babl/utils/value'

module Babl
    module Nodes
        class CreatePin < Utils::Value.new(:node, :ref)
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
