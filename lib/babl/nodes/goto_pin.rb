require 'babl/utils/hash'
require 'values'

module Babl
    module Nodes
        class GotoPin < Value.new(:node, :ref)
            def dependencies
                {}
            end

            def pinned_dependencies
                Babl::Utils::Hash.deep_merge(node.pinned_dependencies, ref => node.dependencies)
            end

            def schema
                node.schema
            end

            def render(ctx)
                node.render(ctx.goto_pin(ref))
            end
        end
    end
end
