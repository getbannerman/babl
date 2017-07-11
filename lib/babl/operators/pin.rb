require 'babl/nodes/create_pin'
require 'babl/nodes/goto_pin'
require 'babl/utils/ref'
require 'babl/errors'

module Babl
    module Operators
        module Pin
            module DSL
                # Create a pin
                def pin(navigation = nil, &block)
                    return pin { |p| block[p.call(navigation)] } if navigation
                    ref = Utils::Ref.new

                    referenced_scope = unscoped.construct_node(key: nil, continue: nil) { |node|
                        Nodes::GotoPin.new(node, ref)
                    }

                    construct_node(continue: nil) { |node| Nodes::CreatePin.new(node, ref) }
                        .call(block[referenced_scope])
                end

                protected

                # Override TemplateBase#precompile to ensure that all pin dependencies are satisfied.
                def precompile
                    super.tap do |node|
                        raise Errors::InvalidTemplateError, 'Unresolved pin' unless node.pinned_dependencies.empty?
                    end
                end
            end
        end
    end
end
