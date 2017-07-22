require 'babl/nodes'

module Babl
    module Operators
        module Nav
            module DSL
                # Navigate to a named property of the current element
                # Multiple properties can be chained
                #
                # A block can also be passed, but in that case, dependency tracking
                # is disabled for the rest of the chain.
                def nav(*path, &block)
                    if path.empty?
                        return (block ? with(unscoped, &block) : construct_node(key: nil, continue: nil) { |node| node })
                    end

                    construct_node(key: nil, continue: nil) { |node| Nodes::Nav.new(path.first, node) }
                        .nav(*path[1..-1], &block)
                end
            end
        end
    end
end
