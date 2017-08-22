# frozen_string_literal: true
module Babl
    module Operators
        module Nullable
            module DSL
                IS_NIL = ->(val) { ::NilClass === val }

                # Nullify the current construction if
                # the current element is Nil.
                def nullable
                    source {
                        switch(
                            nav(&IS_NIL) => nil,
                            default => continue
                        )
                    }
                end
            end
        end
    end
end
