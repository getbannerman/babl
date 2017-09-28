# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Typed
            module DSL
                def integer
                    construct_terminal { Nodes::Typed::Integer.instance }
                end

                def number
                    construct_terminal { Nodes::Typed::Number.instance }
                end

                def string
                    construct_terminal { Nodes::Typed::String.instance }
                end

                def boolean
                    construct_terminal { Nodes::Typed::Boolean.instance }
                end
            end
        end
    end
end
