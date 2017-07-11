require 'values'
require 'set'
require 'babl/schema/static'
require 'babl/schema/object'

module Babl
    module Schema
        class AnyOf < Value.new(:choice_set)
            attr_reader :choices

            def initialize(choices)
                flattened_choices = choices.flat_map { |doc| AnyOf === doc ? doc.choices : [doc] }.uniq
                @choices = flattened_choices
                super(flattened_choices.to_set)
            end

            def json
                { anyOf: choices.map(&:json) }
            end

            # Perform simple transformations in order to reduce the size of the generated
            # schema.
            def simplify
                simplify_single ||
                    simplify_nullability ||
                    simplify_empty_array ||
                    simplify_push_down_dyn_array ||
                    simplify_dyn_and_fixed_array ||
                    simplify_many_objects_only_one_difference ||
                    self
            end

            private

            # We can completely get rid of the AnyOf element of there is only one possible schema.
            def simplify_single
                choices.size == 1 ? choices.first : nil
            end

            # Try to merge nullability into one of the object elements if they support that
            # (Object, DynArray and FixedArray).
            def simplify_nullability
                if choices.include?(Static::NULL)
                    others = choices - [Static::NULL]
                    others.each do |other|
                        new_other =
                            case other
                            when Object then Object.new(other.properties, other.additional, true)
                            when DynArray then DynArray.new(other.item, true)
                            when FixedArray then FixedArray.new(other.items, true)
                            when Anything then other
                            end
                        return AnyOf.new(others - [other] + [new_other]).simplify if new_other
                    end
                end

                nil
            end

            # An always empty FixedArray is just a special case of a DynArray
            # We can get rid of the former and only keep the DynArray
            def simplify_empty_array
                fixed_array = choices.find { |s| FixedArray === s && s.items.empty? }
                if fixed_array
                    others = choices - [fixed_array]
                    others.each do |other|
                        next unless DynArray === other
                        new_other = DynArray.new(other.item, other.nullable || fixed_array.nullable)
                        return AnyOf.new(others - [other] + [new_other]).simplify
                    end
                end

                nil
            end

            # If the static array is an instance of another dyn array, then the fixed array can be
            # removed.
            def simplify_dyn_and_fixed_array
                dyns = choices.select { |s| DynArray === s }
                fixeds = choices.select { |s| FixedArray === s && s.items.uniq.size == 1 }

                dyns.each do |dyn|
                    fixeds.each do |fixed|
                        new_dyn = DynArray.new(dyn.item, dyn.nullable || fixed.nullable)
                        return AnyOf.new(choices - [fixed, dyn] + [new_dyn]).simplify if dyn.item == fixed.items.first
                    end
                end

                nil
            end

            # If two objects have exactly the same structure, with the exception of only one property
            # having a different type, then AnyOf can be pushed down to this property.
            def simplify_many_objects_only_one_difference
                return unless choices.all? { |s| Object === s }

                choices.each_with_index { |obj1, index1|
                    choices.each_with_index { |obj2, index2|
                        next if index2 <= index1
                        next unless Object === obj1 && Object === obj2
                        next unless obj1.nullable == obj2.nullable && obj1.additional == obj2.additional
                        next unless obj1.properties.map { |p| [p.name, p.required] }.to_set ==
                                obj2.properties.map { |p| [p.name, p.required] }.to_set

                        diff1 = obj1.properties - obj2.properties
                        diff2 = obj2.properties - obj1.properties

                        next unless diff1.size == 1 && diff2.size == 1 && diff1.first.name == diff2.first.name

                        merged = Object.new(
                            obj1.properties.map { |p|
                                next p unless p == diff1.first
                                Object::Property.new(
                                    p.name,
                                    AnyOf.new([diff1.first.value, diff2.first.value]).simplify,
                                    p.required
                                )
                            },
                            obj1.additional,
                            obj1.nullable
                        )

                        return AnyOf.new(choices - [obj1, obj2] + [merged]).simplify
                    }
                }

                nil
            end

            # Push down the AnyOf to the item if all outputs are of type DynArray
            def simplify_push_down_dyn_array
                return unless choices.all? { |s| DynArray === s }
                DynArray.new(AnyOf.new(choices.map(&:item)).simplify, choices.any?(&:nullable))
            end
        end
    end
end
