module Babl
    module Operators
        module Each
            module DSL
                # Construct a JSON array by iterating over the current collection,
                # using the chained template for rendering each element.
                def each
                    construct_node(key: nil, continue: nil) { |node| EachNode.new(node) }
                end
            end

            class EachNode
                def initialize(node)
                    @node = node
                end

                def dependencies
                    { __each__: node.dependencies }
                end

                def documentation
                    [node.documentation]
                end

                def pinned_dependencies
                    node.pinned_dependencies
                end

                def render(ctx)
                    collection = ctx.object

                    unless collection.is_a?(Enumerable)
                        raise RenderingError, "Object is not enumerable : #{collection.inspect}"
                    end

                    collection.each_with_index.map { |value, idx| node.render(ctx.move_forward(value, idx)) }
                end

                private

                attr_reader :node
            end
        end
    end
end
