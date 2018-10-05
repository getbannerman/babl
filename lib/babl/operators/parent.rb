# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Parent
            module DSL
                # Navigate to the parent of the current object.
                def parent
                    construct_node { |node| Nodes::Parent.new(node) }.reset_key.reset_continue
                end

                protected

                def validate(tree)
                    if tree.dependencies.key? Nodes::Parent::PARENT_MARKER
                        raise Errors::InvalidTemplate, 'Out of context parent dependency'
                    end

                    super
                end
            end
        end
    end
end
