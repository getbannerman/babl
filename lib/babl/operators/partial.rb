# frozen_string_literal: true
require 'babl/errors'

module Babl
    module Operators
        module Partial
            module DSL
                # Load a partial template given its name
                # A 'lookup_context' must be defined
                def partial(partial_name)
                    current_template = unscoped
                    construct_terminal { |ctx|
                        lookup_context = ctx[:lookup_context]
                        raise Errors::InvalidTemplate, 'Cannot use partial without lookup context' unless lookup_context

                        template, new_lookup_context = lookup_context.find(current_template, partial_name)
                        raise Errors::InvalidTemplate, "Cannot find partial '#{partial_name}'" unless template

                        template.precompile(Nodes::TerminalValue.instance, lookup_context: new_lookup_context)
                    }
                end
            end
        end
    end
end
