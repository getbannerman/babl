require 'babl/nodes/typed'

module Babl
    module Operators
        module Typed
            module DSL
                def integer
                    construct_node(continue: nil) { |node| Nodes::Typed::INTEGER.call(node) }
                end

                def number
                    construct_node(continue: nil) { |node| Nodes::Typed::NUMBER.call(node) }
                end

                def string
                    construct_node(continue: nil) { |node| Nodes::Typed::STRING.call(node) }
                end

                def boolean
                    construct_node(continue: nil) { |node| Nodes::Typed::BOOLEAN.call(node) }
                end
            end
        end
    end
end
