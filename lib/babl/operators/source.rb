# frozen_string_literal: true
module Babl
    module Operators
        module Source
            module DSL
                # Parse BABL source into a Template
                def source(*args, &block)
                    call(unscoped.instance_eval(*args, &block))
                end
            end
        end
    end
end
