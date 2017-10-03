# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Concat
            module DSL
                # Produce an array by concatening the provided result of the given templates.
                # (they therefor have to produce arrays, or nil, which is interpreted as an empty array)
                def concat(*templates)
                    templates = templates.map { |t| unscoped.call(t) }

                    construct_terminal { |context|
                        Nodes::Concat.new(
                            templates.map { |t|
                                t.builder.precompile(
                                    Nodes::TerminalValue.instance,
                                    context.merge(continue: nil)
                                )
                            }
                        )
                    }
                end
            end
        end
    end
end
