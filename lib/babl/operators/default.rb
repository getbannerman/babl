# frozen_string_literal: true
module Babl
    module Operators
        module Default
            module DSL
                # To be used as a switch(...) condition. It is strictly equivalent to write 'true' instead,
                # but it conveys more meaning.
                def default
                    static(true)
                end
            end
        end
    end
end
