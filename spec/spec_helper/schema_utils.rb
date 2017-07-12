require 'babl'

module SpecHelper
    module SchemaUtils
        def s_any_of(*args)
            Babl::Schema::AnyOf.canonical(args)
        end

        def s_anything
            Babl::Schema::Anything.instance
        end

        def s_dyn_array(schema)
            Babl::Schema::DynArray.new(schema)
        end

        def s_null
            Babl::Schema::Static::NULL
        end

        def s_fixed_array(*schemas)
            Babl::Schema::FixedArray.new(schemas)
        end

        def s_object(*properties, additional: false)
            Babl::Schema::Object.new(properties, additional)
        end

        def s_static(value)
            Babl::Schema::Static.new(value)
        end

        def s_property(name, value, required: true)
            Babl::Schema::Object::Property.new(name, value, required)
        end
    end
end
