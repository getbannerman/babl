module Babl
    module Operators
        module Nullable
            module DSL
                # Nullify the current construction if
                # the current element is Nil.
                def nullable
                    switch(
                        unscoped.nav(&:nil?) => nil,
                        unscoped.default => unscoped.continue
                    )
                end
            end
        end
    end
end
