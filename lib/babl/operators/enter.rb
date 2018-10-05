# frozen_string_literal: true
require 'babl/errors'
require 'babl/nodes'

module Babl
    module Operators
        module Enter
            module DSL
                # Navigate to a named property of current element. The name
                # is inferred based on the object()
                def enter
                    construct_node { |node, context|
                        key = context[:key]
                        raise Errors::InvalidTemplate, 'No key to enter into' unless key

                        Nodes::Nav.new(key, node)
                    }.reset_key.reset_continue
                end

                # Simple convenience alias
                def _
                    enter
                end

                protected

                # Clear contextual information about current property name for the rest of the chain
                def reset_key
                    construct_context { |context| context.merge(key: nil) }
                end
            end
        end
    end
end
