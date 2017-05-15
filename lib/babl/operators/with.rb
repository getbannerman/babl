module Babl
    module Operators
        module With
            module DSL
                # Produce a value by calling the block, passing it the output value of the templates passed as argument.
                def with(*templates, &block)
                    construct_node(key: nil, continue: nil) do |node, context|
                        WithNode.new(node, templates.map do |t|
                            unscoped.call(t).builder.precompile(
                                Rendering::InternalValueNode.instance,
                                context.merge(continue: nil)
                            )
                        end, block)
                    end
                end
            end

            class WithNode
                def initialize(node, nodes, block)
                    @node = node
                    @nodes = nodes
                    @block = block
                end

                def documentation
                    node.documentation
                end

                def dependencies
                    # Dependencies of 'node' are explicitely ignored
                    nodes.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def pinned_dependencies
                    (nodes + [node]).map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def render(ctx)
                    values = nodes.map { |n| n.render(ctx) }
                    node.render(ctx.move_forward_block(:__block__) do
                        block.arity.zero? ? ctx.object.instance_exec(&block) : block.call(*values)
                    end)
                end

                private

                attr_reader :node, :nodes, :block
            end
        end
    end
end
