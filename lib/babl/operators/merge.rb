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

                    templates = templates.map { |t| unscoped.reset_continue.call(t) }

                    construct_terminal { |context|
                        Nodes::Merge.new(
                            templates.map { |t|
                                t.builder.precompile(Nodes::TerminalValue.instance, context)
                            }
                        )
                    }
                end
            end
        end
    end
end
