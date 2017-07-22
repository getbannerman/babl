require 'babl/nodes'

module Babl
    module Operators
        module Parent
            module DSL
                # Navigate to the parent of the current object.
                def parent
                    construct_node(key: nil, continue: nil) { |node| Nodes::Parent.new(node) }
                end

                protected

                # Override TemplateBase#precompile to add parent dependencies verification
                def precompile
                    Nodes::Parent::Resolver.new(super)
                end
            end
        end
    end
end
