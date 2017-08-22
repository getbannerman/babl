# frozen_string_literal: true
module Babl
    module Operators
        module Null
            module DSL
                # This operator always produces a JSON 'null'.
                # We need it because a JSON file is also a valid
                # BABL file (only if it is also a valid Ruby file,
                # of course)
                def null
                    static(nil)
                end
            end
        end
    end
end
