# frozen_string_literal: true
require 'babl/nodes'
require 'babl/utils'

module Babl
    module Operators
        module Switch
            module DSL
                # Conditional switching between different templates
                def switch(conds = Utils::Hash::EMPTY)
                    conds = conds.map { |cond, value| [unscoped.call(cond), unscoped.call(value)] }

                    construct_node(continue: nil) { |node, context|
                        nodes = conds.map { |cond, value|
                            cond_node = cond.builder.precompile(
                                Nodes::InternalValue.instance,
                                context.merge(continue: nil)
                            )

                            value_node = value.builder.precompile(
                                Nodes::TerminalValue.instance,
                                context.merge(continue: node)
                            )

                            [cond_node, value_node]
                        }

                        Nodes::Switch.new(nodes)
                    }
                end
            end
        end
    end
end
