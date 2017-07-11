require 'babl/nodes/fixed_array'
require 'babl/nodes/terminal_value'

module Babl
    module Operators
        module Array
            module DSL
                # Produce an fixed-size array, using the provided templates to populate its elements.
                def array(*templates)
                    construct_terminal { |ctx|
                        Nodes::FixedArray.new(templates.map { |t|
                            unscoped.call(t).builder.precompile(Nodes::TerminalValue.instance, ctx.merge(continue: nil))
                        })
                    }
                end
            end
        end
    end
end
