# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Schema
        class Static < Utils::Value.new(:value, :json)
            def initialize(value)
                super(value, ::NilClass === value ? { type: 'null' } : { enum: [value] })
            end

            NULL = new(nil)
            TRUE = new(true)
            FALSE = new(false)
        end
    end
end
