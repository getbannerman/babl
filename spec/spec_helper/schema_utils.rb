require 'babl'

module SpecHelper
    module SchemaUtils
        def s_any_of(*args)
            Babl::Schema::AnyOf.new(args)
        end

        def s_anything
            Babl::Schema::Anything.instance
        end

        def s_dyn_array(schema, nullable: false)
            Babl::Schema::DynArray.new(schema, nullable)
        end

        def s_fixed_array(*schemas, nullable: false)
            Babl::Schema::FixedArray.new(schemas, nullable)
        end

        def s_object(*properties, additional: false, nullable: false)
            Babl::Schema::Object.new(properties, additional, nullable)
        end

        def s_static(value)
            Babl::Schema::Static.new(value)
        end

        def s_property(name, value, required: true)
            Babl::Schema::Object::Property.new(name, value, required)
        end
    end
end
