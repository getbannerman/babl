# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Nullable
            module DSL
                # Nullify the current construction if
                # the current element is Nil.
                def nullable
                    source {
                        switch(
                            construct_terminal { Nodes::IsNull.instance } => nil,
                            default => continue
                        )
                    }
                end
            end
        end
    end
end
