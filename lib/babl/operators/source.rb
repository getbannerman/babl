# frozen_string_literal: true
require 'babl/utils'
module Babl
    module Operators
        module Source
            module DSL
                # Parse BABL source into a Template
                def source(*args, &block)
                    call(block ? Utils::DslProxy.eval(unscoped, &block) : unscoped.instance_eval(*args))
                end
            end
        end
    end
end
