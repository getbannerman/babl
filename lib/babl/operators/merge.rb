# frozen_string_literal: true
require 'babl/nodes'
require 'babl/utils'

module Babl
    module Operators
        module Merge
            module DSL
                # Merge multiple JSON objects (non-deep)
                def merge(*templates)
                    return call(Utils::Hash::EMPTY) if templates.empty?

                    construct_terminal { |context|
                        Nodes::Merge.build(
                            templates.map { |t|
                                unscoped.call(t).builder.precompile(
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
