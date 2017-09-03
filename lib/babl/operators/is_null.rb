# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module IsNull
            module DSL
                def is_null
                    construct_terminal { Nodes::IsNull.instance }
                end
            end
        end
    end
end
