require 'babl/nodes'

module Babl
    module Operators
        module Typed
            module DSL
                def integer
                    construct_terminal { Nodes::Typed::INTEGER }
                end

                def number
                    construct_terminal { Nodes::Typed::NUMBER }
                end

                def string
                    construct_terminal { Nodes::Typed::STRING }
                end

                def boolean
                    construct_terminal { Nodes::Typed::BOOLEAN }
                end
            end
        end
    end
end
