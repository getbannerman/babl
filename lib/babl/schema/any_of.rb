require 'babl/utils'
require 'babl/schema'
require 'set'

module Babl
    module Schema
        class AnyOf < Utils::Value.new(:choice_set)
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
                    simplify_anything ||
                    simplify_boolean ||
                    simplify_typed_and_static ||
                    simplify_empty_array ||
                    simplify_push_down_dyn_array ||
                    simplify_dyn_and_fixed_array ||
                    simplify_many_objects_only_one_difference ||
                    self
            end

            def self.canonicalized(choices)
                new(choices).simplify
            end

            private

            # We can completely get rid of the AnyOf element of there is only one possible schema.
            def simplify_single
                choices.size == 1 ? choices.first : nil
            end

            # AnyOf[anything, string, number...] always collapse to anything.
            def simplify_anything
                choice_set.include?(Anything.instance) ? Anything.instance : nil
            end

            # AnyOf[true, false] is just boolean
            def simplify_boolean
                return unless choice_set.include?(Static::TRUE) && choice_set.include?(Static::FALSE)
                AnyOf.canonicalized(choice_set - [Static::TRUE, Static::FALSE] + [Typed::BOOLEAN])
            end

            # AnyOf[string, 'a string instance', 'another string'] is just string
            # AnyOf[boolean, true, false] is just boolean
            # AnyOf[number, 2, 3.1] is just number
            # AnyOf[integer, 2, 1] is just integer
            def simplify_typed_and_static
                choices.each do |typed|
                    next unless Typed === typed
                    instances = choices.select { |instance|
                        Static === instance && typed.classes.any? { |clazz| clazz === instance.value }
                    }
                    next if instances.empty?
                    return AnyOf.canonicalized(choice_set - instances)
                end
                nil
            end

            # An always empty FixedArray is just a special case of a DynArray
            # We can get rid of the former and only keep the DynArray
            def simplify_empty_array
                return unless choice_set.include?(FixedArray::EMPTY)
                choice_set.each do |other|
                    next unless DynArray === other
                    new_other = DynArray.new(other.item)
                    return AnyOf.canonicalized(choice_set - [other, FixedArray::EMPTY] + [new_other])
                end
                nil
            end

            # If the static array is an instance of another dyn array, then the fixed array can be
            # removed.
            def simplify_dyn_and_fixed_array
                fixed_arrays = choices.select { |s| FixedArray === s && s.items.uniq.size == 1 }
                return if fixed_arrays.empty?

                choices.each do |dyn|
                    next unless DynArray === dyn
                    fixed_arrays.each do |fixed|
                        new_dyn = DynArray.new(dyn.item)
                        return AnyOf.canonicalized(choice_set - [fixed, dyn] + [new_dyn]) if dyn.item == fixed.items.first
                    end
                end

                nil
            end

            # If two objects have exactly the same structure, with the exception of only one property
            # having a different type, then AnyOf can be pushed down to this property.
            def simplify_many_objects_only_one_difference
                choices.each_with_index { |obj1, index1|
                    next unless Object === obj1

                    choices.each_with_index { |obj2, index2|
                        break if index2 >= index1

                        next unless Object === obj2 &&
                                obj1.additional == obj2.additional &&
                                obj1.properties.map { |p| [p.name, p.required] }.to_set ==
                                        obj2.properties.map { |p| [p.name, p.required] }.to_set

                        diff1 = obj1.properties - obj2.properties
                        diff2 = obj2.properties - obj1.properties

                        next unless diff1.size == 1 && diff2.size == 1 && diff1.first.name == diff2.first.name

                        merged = Object.new(
                            obj1.properties.map { |property|
                                next property unless property == diff1.first
                                Object::Property.new(
                                    property.name,
                                    AnyOf.canonicalized([diff1.first.value, diff2.first.value]),
                                    property.required
                                )
                            },
                            obj1.additional
                        )

                        return AnyOf.canonicalized(choice_set - [obj1, obj2] + [merged])
                    }
                }

                nil
            end

            # Push down the AnyOf to the item if all outputs are of type DynArray
            def simplify_push_down_dyn_array
                choices.each_with_index { |arr1, index1|
                    next unless DynArray === arr1
                    choices.each_with_index { |arr2, index2|
                        break if index2 >= index1
                        next unless DynArray === arr2
                        new_arr = DynArray.new(AnyOf.canonicalized([arr1.item, arr2.item]))
                        return AnyOf.canonicalized(choice_set - [arr1, arr2] + [new_arr])
                    }
                }
                nil
            end
        end
    end
end
