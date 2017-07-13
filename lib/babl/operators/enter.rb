require 'babl/errors'

module Babl
    module Operators
        module Enter
            module DSL
                # Navigate to a named property of current element. The name
                # is inferred based on the object()
                def enter
                    construct_node(key: nil, continue: nil) { |node, context|
                        key = context[:key]
                        raise Errors::InvalidTemplate, "No key to enter into" unless key
                        Nodes::Nav.new(key, node)
                    }
                end

                # Simple convenience alias
                def _
                    enter
                end
            end
        end
    end
end
