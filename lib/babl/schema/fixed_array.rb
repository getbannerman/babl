require 'babl/utils'

module Babl
    module Schema
        class FixedArray < Utils::Value.new(:items)
            EMPTY = new([])

            def json
                { type: 'array', items: items.map(&:json) }
            end
        end
    end
end
