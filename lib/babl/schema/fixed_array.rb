require 'values'

module Babl
    module Schema
        class FixedArray < Value.new(:items)
            EMPTY = new([])

            def json
                { type: 'array', items: items.map(&:json) }
            end
        end
    end
end
