require 'values'

module Babl
    module Schema
        class FixedArray < Value.new(:items, :nullable)
            EMPTY = new([], false)

            def json
                { type: nullable ? %w[array null] : 'array', items: items.map(&:json) }
            end
        end
    end
end
