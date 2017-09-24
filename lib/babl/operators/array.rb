# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Array
            module DSL
                # Produce an fixed-size array, using the provided templates to populate its elements.
                def array(*templates)
                    templates = templates.map { |t| unscoped.call(t) }

                    construct_terminal { |ctx|
                        Nodes::FixedArray.new(templates.map { |t|
                            t.builder.precompile(Nodes::TerminalValue.instance, ctx.merge(continue: nil))
                        })
                    }
                end
            end
        end
    end
end
