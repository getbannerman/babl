# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Dep
            module DSL
                # Declare dependencies as if they were generated by nav()
                # but without navigating.
                def dep(*path)
                    construct_node(continue: nil) { |node| Nodes::Dep.new(node, path) }
                end
            end
        end
    end
end
