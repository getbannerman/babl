require 'values'

module Babl
    module Nodes
        class Nav < Value.new(:through, :node)
            def dependencies
                { through => node.dependencies }
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(ctx)
                node.render(ctx.move_forward_block(through) { navigate(ctx.object) })
            end

            private

            def navigate(object)
                if ::Hash === object
                    object.fetch(through)
                else
                    object.send(through)
                end
            end
        end
    end
end
