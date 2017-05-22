module Babl
    module Operators
        module Nullable
            module DSL
                # Nullify the current construction if
                # the current element is Nil.
                def nullable
                    source {
                        switch(
                            nav(&:nil?) => nil,
                            default => continue
                        )
                    }
                end
            end
        end
    end
end
