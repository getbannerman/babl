# frozen_string_literal: true
require 'babl/errors'

module Babl
    module Operators
        module Continue
            module DSL
                # Return a special placeholder that can be used as a switch(...) value. It tells BABL to continue
                # the evaluation of the original chain after switch().
                def continue
                    construct_terminal { |context|
                        node = context[:continue]
                        raise Errors::InvalidTemplate, 'continue() cannot be used outside switch()' unless node

                        node
                    }
                end

                protected

                # Clear contextual information about parent switch for the rest of the chain
                def reset_continue
                    construct_context { |context|
                        next context unless context.key?(:continue)

                        context.reject { |k, _v| :continue == k }
                    }
                end
            end
        end
    end
end
