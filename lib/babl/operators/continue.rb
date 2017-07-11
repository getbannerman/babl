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
                        raise Errors::InvalidTemplateError, 'continue() cannot be used outside switch()' unless node
                        node
                    }
                end
            end
        end
    end
end
