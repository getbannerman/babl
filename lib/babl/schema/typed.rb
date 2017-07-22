require 'babl/utils'

module Babl
    module Schema
        class Typed < Utils::Value.new(:type, :classes)
            INTEGER = new('integer', [::Integer])
            BOOLEAN = new('boolean', [::TrueClass, ::FalseClass])
            NUMBER = new('number', [::Numeric])
            STRING = new('string', [::String])

            def json
                { type: type }
            end
        end
    end
end
