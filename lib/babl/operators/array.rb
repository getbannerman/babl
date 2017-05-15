module Babl
    module Operators
        module Array
            module DSL
                # Produce an fixed-size array, using the provided templates to populate its elements.
                def array(*templates)
                    construct_terminal { |ctx|
                        FixedArrayNode.new(templates.map { |t|
                            unscoped.call(t).builder.precompile(Rendering::TerminalValueNode.instance, ctx.merge(continue: nil))
                        })
                    }
                end
            end

            class FixedArrayNode
                def initialize(nodes)
                    @nodes = nodes
                end

                def documentation
                    nodes.map(&:documentation)
                end

                def dependencies
                    nodes.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def pinned_dependencies
                    nodes.map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def render(ctx)
                    nodes.map { |node| node.render(ctx) }
                end

                private

                attr_reader :nodes
            end
        end
    end
end
