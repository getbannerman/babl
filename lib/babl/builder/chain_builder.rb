# frozen_string_literal: true
require 'babl/nodes'
require 'babl/errors'

module Babl
    module Builder
        # Builder provides a simple framework for defining & chaining BABL's operators easily.
        #
        # Compiling a template is a multi-phase process:
        #
        # 1- [BABL => ChainBuilder] Template definition (via Builder#construct_node & Builder#construct_terminal) :
        #        The operator chain is created by wrapping blocks (current block stored in 'scope')
        #
        # 2- [Builder => BoundOperator] Template binding (via Builder#bind) :
        #        A BoundOperator is created for each operator and passed to the next, in left-to-right
        #        order. This step is necessary to propagate context from root to leaves. A typical
        #        use-case is the 'enter' operator, which requires the parent context in which it is called.
        #
        # 3- [BoundOperator => Node] Node precompilation (via Builder#precompile):
        #        BoundOperators are transformed into a Node tree, in right-to-left order. Each node
        #        contains its own rendering logic, dependency tracking & documentation generator.
        #
        # 4- [Node => CompiledTemplate] Compilation output: (via Template#compile):
        #        The resulting Node is used to compute the dependencies & generate the documentation.
        #        Finally, we pack everything is a CompiledTemplate which is exposed to the user.
        #
        class ChainBuilder
            def initialize(&block)
                @scope = block
            end

            def precompile(node, context)
                bind(BoundOperator.new(context, &:itself)).scope.call(node)
            end

            def bind(bound)
                @scope[bound]
            end

            # Append a terminal operator, and return a new Builder object
            def construct_terminal
                construct_node do |node, context|
                    unless [Nodes::InternalValue.instance, Nodes::TerminalValue.instance].include?(node)
                        raise Errors::InvalidTemplate, 'Chaining is not allowed after a terminal operator'
                    end

                    yield context
                end
            end

            # Append an operator to the chain, and return a new Builder object
            def construct_node
                wrap { |bound|
                    BoundOperator.new(bound.context) { |node| bound.scope[yield(node, bound.context)] }
                }
            end

            def construct_context
                wrap { |bound|
                    new_context = yield(bound.context)
                    next bound if bound.context.equal?(new_context)

                    BoundOperator.new(new_context, &bound.scope)
                }
            end

            def wrap
                ChainBuilder.new { |bound| yield bind(bound) }
            end
        end

        class BoundOperator
            attr_reader :context, :scope

            def initialize(context, &scope)
                @context = context
                @scope = scope
            end
        end
    end
end
