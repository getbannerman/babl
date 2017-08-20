require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Parent < Utils::Value.new(:node)
            PARENT_MARKER = Utils::Ref.new

            class Resolver < Utils::Value.new(:node)
                def dependencies
                    backpropagate_dependencies(node.dependencies)
                end

                def schema
                    node.schema
                end

                def pinned_dependencies
                    node.pinned_dependencies
                end

                def render(ctx)
                    node.render(ctx)
                end

                private

                def backpropagate_dependencies(deps)
                    raise Errors::InvalidTemplate, 'Out of context parent dependency' if deps.key? PARENT_MARKER
                    new_deps = backpropagate_dependencies_one_level(deps)
                    deps == new_deps ? new_deps : backpropagate_dependencies(new_deps)
                end

                def backpropagate_dependencies_one_level(deps)
                    deps.reduce(Utils::Hash::EMPTY) do |out, (k, v)|
                        next out if k == PARENT_MARKER

                        Babl::Utils::Hash.deep_merge(
                            Babl::Utils::Hash.deep_merge(out, k => backpropagate_dependencies_one_level(v)),
                            v[PARENT_MARKER] || Utils::Hash::EMPTY
                        )
                    end
                end
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def dependencies
                { PARENT_MARKER => node.dependencies }
            end

            def render(ctx)
                node.render(ctx.move_backward)
            end
        end
    end
end
