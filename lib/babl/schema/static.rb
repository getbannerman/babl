require 'values'

module Babl
    module Schema
        class Static < ::Value.new(:value)
            NULL = new(nil)

            def json
                return { type: 'null' } if value.nil?
                { enum: [value] }
            end
        end
    end
end
