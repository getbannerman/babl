# frozen_string_literal: true
require 'babl'

module SpecHelper
    module SchemaUtils
        def s_any_of(*args)
            Babl::Schema::AnyOf.new(args)
        end

        def s_anything
            Babl::Schema::Anything.instance
        end

        def s_dyn_array(schema)
            Babl::Schema::DynArray.new(schema)
        end

        def s_null
            Babl::Schema::Primitive::NULL
        end

        def s_integer
            Babl::Schema::Typed::INTEGER
        end

        def s_string
            Babl::Schema::Typed::STRING
        end

        def s_boolean
            Babl::Schema::Typed::BOOLEAN
        end

        def s_number
            Babl::Schema::Typed::NUMBER
        end

        def s_fixed_array(*schemas)
            Babl::Schema::FixedArray.new(schemas)
        end

        def s_object(*properties, additional: false)
            Babl::Schema::Object.new(properties, additional)
        end

        def s_primitive(value)
            Babl::Schema::Primitive.new(value)
        end

        def s_property(name, value, required: true)
            Babl::Schema::Object::Property.new(name, value, required)
        end
    end
end
