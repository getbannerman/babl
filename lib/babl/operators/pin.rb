# frozen_string_literal: true
require 'babl/nodes'
require 'babl/utils'
require 'babl/errors'

module Babl
    module Operators
        module Pin
            module DSL
                # Create a pin
                def pin(navigation = unscoped, &block)
                    ref = Utils::Ref.new
                    named_pin(ref).call(block[unscoped.goto_pin(ref).call(navigation)])
                end

                def named_pin(ref)
                    check_pin_ref(ref)
                    construct_node(continue: nil) { |node| Nodes::CreatePin.new(node, ref) }
                end

                def goto_pin(ref)
                    check_pin_ref(ref)
                    construct_node(key: nil, continue: nil) { |node| Nodes::GotoPin.new(node, ref) }
                end

                protected

                def validate(tree)
                    name = tree.pinned_dependencies.keys.first
                    raise Errors::InvalidTemplate, "Unresolved pin: #{name}" if name
                    super
                end

                def check_pin_ref(ref)
                    raise Errors::InvalidTemplate, 'Pin name must be a symbol' unless Utils::Ref === ref || ::Symbol === ref
                end
            end
        end
    end
end
