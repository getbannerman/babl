# frozen_string_literal: true
require 'babl/utils'
module Babl
    module Operators
        module Source
            module DSL
                # Parse BABL source into a Template
                def source(*args, &block)
                    raise Errors::InvalidTemplate, 'source() expects a block xor a string' unless args.empty? ^ block.nil?

                    block ||= proc { instance_eval(*args) }
                    call Utils::DslProxy.eval(unscoped, &block)
                end
            end
        end
    end
end
