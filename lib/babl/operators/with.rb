# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module With
            module DSL
                # Produce a value by calling the block, passing it the output value of the templates passed as argument.
                def with(*templates, &block)
                    templates = templates.map { |t| unscoped.call(t) }

                    construct_node(key: nil, continue: nil) do |node, context|
                        Nodes::With.new(node, templates.map { |t|
                            t.builder.precompile(
                                Nodes::InternalValue.instance,
                                context.merge(continue: nil)
                            )
                        }, block)
                    end
                end
            end
        end
    end
end
