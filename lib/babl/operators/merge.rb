require 'babl/nodes/merge'
require 'babl/nodes/terminal_value'

module Babl
    module Operators
        module Merge
            module DSL
                # Merge multiple JSON objects (non-deep)
                def merge(*templates)
                    return call({}) if templates.empty?

                    construct_terminal { |context|
                        Nodes::Merge.new(
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
