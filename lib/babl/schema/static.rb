require 'babl/utils'

module Babl
    module Schema
        class Static < Utils::Value.new(:value)
            NULL = new(nil)
            TRUE = new(true)
            FALSE = new(false)

            def json
                return { type: 'null' } if value.nil?
                { enum: [value] }
            end
        end
    end
end
