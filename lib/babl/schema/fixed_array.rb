# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Schema
        class FixedArray < Utils::Value.new(:items)
            EMPTY = new(Utils::Array::EMPTY)

            def json
                if items.empty?
                    { enum: [Utils::Array::EMPTY] }
                else
                    { type: 'array', items: items.map(&:json), additionalItems: false }
                end
            end
        end
    end
end
