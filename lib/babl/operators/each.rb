# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Each
            module DSL
                # Construct a JSON array by iterating over the current collection,
                # using the chained template for rendering each element.
                def each
                    construct_node(key: nil, continue: nil) { |node| Nodes::Each.new(node) }
                end
            end
        end
    end
end
