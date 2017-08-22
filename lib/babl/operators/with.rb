# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module With
            module DSL
                # Produce a value by calling the block, passing it the output value of the templates passed as argument.
                def with(*templates, &block)
                    construct_node(key: nil, continue: nil) do |node, context|
                        Nodes::With.new(node, templates.map do |t|
                            unscoped.call(t).builder.precompile(
                                Nodes::InternalValue.instance,
                                context.merge(continue: nil)
                            )
                        end, block)
                    end
                end
            end
        end
    end
end
