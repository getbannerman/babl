module Babl
    module Operators
        module Parent
            PARENT = ::Object.new

            module DSL
                # Navigate to the parent of the current object.
                def parent
                    construct_node(key: nil, continue: nil) { |node| ParentNode.new(node) }
                end

                protected

                # Override TemplateBase#precompile to add parent dependencies verification
                def precompile
                    ParentResolverNode.new(super)
                end
            end

            class ParentResolverNode
                def initialize(node)
                    @node = node
                end

                def dependencies
                    backpropagate_dependencies(node.dependencies)
                end

                def documentation
                    node.documentation
                end

                def pinned_dependencies
                    node.pinned_dependencies
                end

                def render(ctx)
                    node.render(ctx)
                end

                private

                attr_reader :node

                def backpropagate_dependencies(deps)
                    raise InvalidTemplateError, 'Out of context parent dependency' if deps.key? PARENT
                    new_deps = backpropagate_dependencies_one_level(deps)
                    deps == new_deps ? new_deps : backpropagate_dependencies(new_deps)
                end

                def backpropagate_dependencies_one_level(deps)
                    deps.reduce({}) do |out, (k, v)|
                        next out if k == PARENT

                        Babl::Utils::Hash.deep_merge(
                            Babl::Utils::Hash.deep_merge(out, k => backpropagate_dependencies_one_level(v)),
                            v[PARENT] || {}
                        )
                    end
                end
            end

            class ParentNode
                def initialize(node)
                    @node = node
                end

                def documentation
                    node.documentation
                end

                def pinned_dependencies
                    node.pinned_dependencies
                end

                def dependencies
                    { PARENT => node.dependencies }
                end

                def render(ctx)
                    node.render(ctx.move_backward)
                end

                private

                attr_reader :node
            end
        end
    end
end
