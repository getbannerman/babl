module Babl
    module Operators
        module Nav
            module DSL
                # Navigate to a named property of the current element
                # Multiple properties can be chained
                #
                # A block can also be passed, but in that case, dependency tracking
                # is disabled for the rest of the chain.
                def nav(*path, &block)
                    if path.empty?
                        return (block ? with(unscoped, &block) : construct_node(key: nil, continue: nil) { |node| node })
                    end

                    construct_node(key: nil, continue: nil) { |node| NavNode.new(path.first, node) }.nav(*path[1..-1], &block)
                end
            end

            class NavNode
                def initialize(through, node)
                    @through = through
                    @node = node
                end

                def dependencies
                    { through => node.dependencies }
                end

                def documentation
                    node.documentation
                end

                def pinned_dependencies
                    node.pinned_dependencies
                end

                def render(ctx)
                    node.render(ctx.move_forward_block(through) { navigate(ctx.object) })
                end

                private

                attr_reader :through, :node

                def navigate(object)
                    if object.is_a?(Hash)
                        object.fetch(through)
                    else
                        object.send(through)
                    end
                end
            end
        end
    end
end
