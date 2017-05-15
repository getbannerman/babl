module Babl
    module Operators
        module Pin
            module DSL
                # Create a pin
                def pin(navigation = nil, &block)
                    return pin { |p| block[p.call(navigation)] } if navigation
                    ref = ::Object.new
                    referenced_scope = unscoped.construct_node(key: nil, continue: nil) { |node| GotoPinNode.new(node, ref) }
                    construct_node(continue: nil) { |node| CreatePinNode.new(node, ref) }.call(block[referenced_scope])
                end

                protected

                # Override TemplateBase#precompile to ensure that all pin dependencies are satisfied.
                def precompile
                    super.tap do |node|
                        raise Babl::InvalidTemplateError, 'Unresolved pin' unless node.pinned_dependencies.empty?
                    end
                end
            end

            class CreatePinNode
                def initialize(node, ref)
                    @node = node
                    @ref = ref
                end

                def render(ctx)
                    node.render(ctx.create_pin(ref))
                end

                def documentation
                    node.documentation
                end

                def dependencies
                    Babl::Utils::Hash.deep_merge(node.dependencies, node.pinned_dependencies[ref] || {})
                end

                def pinned_dependencies
                    node.pinned_dependencies.reject { |k, _v| k == ref }
                end

                private

                attr_reader :node, :ref
            end

            class GotoPinNode
                def initialize(node, ref)
                    @node = node
                    @ref = ref
                end

                def dependencies
                    {}
                end

                def pinned_dependencies
                    Babl::Utils::Hash.deep_merge(node.pinned_dependencies, ref => node.dependencies)
                end

                def documentation
                    node.documentation
                end

                def render(ctx)
                    node.render(ctx.goto_pin(ref))
                end

                private

                attr_reader :node, :ref
            end
        end
    end
end
