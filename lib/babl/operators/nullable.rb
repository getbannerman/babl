# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Nullable
            module DSL
                # Nullify the current construction if the condition is truthy.
                # By default, it produces null when the current element is Nil.
                def nullable(nullcond = unscoped.is_null)
                    source {
                        switch(
                            nullcond => nil,
                            default => continue
                        )
                    }
                end
            end
        end
    end
end
