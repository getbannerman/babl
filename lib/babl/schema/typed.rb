# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Schema
        class Typed < Utils::Value.new(:type, :classes, :json)
            def initialize(type, classes)
                super(type.freeze, classes.freeze, { type: type }.freeze)
            end

            INTEGER = new('integer', [::Integer])
            BOOLEAN = new('boolean', [::TrueClass, ::FalseClass])
            NUMBER = new('number', [::Numeric])
            STRING = new('string', [::String])
        end
    end
end
