# frozen_string_literal: true
require 'babl/utils'
require 'babl/schema'
require 'set'

module Babl
    module Schema
        class AnyOf < Utils::Value.new(:choice_set)
            def initialize(choices)
                flattened_choices = choices.flat_map { |doc| AnyOf === doc ? doc.choice_set.to_a : [doc] }.uniq
                super(flattened_choices.to_set.freeze)
            end

            def json
                json_only_primitives || json_coalesced_types || json_general_case
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
                    simplify_merge_objects ||
                    simplify_integer_is_number ||
                    simplify_many_fixed_arrays ||
                    self
            end

            def self.canonicalized(choices)
                new(choices).simplify
            end

            private

            def json_only_primitives
                return { enum: choice_set.map(&:value) } if choice_set.all? { |c| Primitive === c }
            end

            def json_coalesced_types
                remaining = choice_set.dup
                json_types = []

                [Primitive::NULL, Typed::INTEGER, Typed::BOOLEAN, Typed::NUMBER, Typed::STRING].each do |coalescible|
                    if remaining.include?(coalescible)
                        json_types << coalescible.json[:type]
                        remaining.delete(coalescible)
                    end
                end

                # Note: ideally, we would like to turn :
                #   {"anyOf": [{"type": "null"},{"type": "object", ...}]}
                # into
                #   {"type": ["null", "object"], ...}
                # but https://github.com/bcherny/json-schema-to-typescript has trouble converting
                # from the latter format and that's an issue for us.
                return { type: json_types.uniq } if remaining.empty?
            end

            def json_general_case
                { anyOf: choice_set.map(&:json) }
            end

            def simplify_integer_is_number
                return unless choice_set.include?(Typed::INTEGER) && choice_set.include?(Typed::NUMBER)
                AnyOf.canonicalized(choice_set - [Typed::INTEGER])
            end

            # AnyOf[FixedArray(Item1, Item2), FixedArray(Item3, Item4)] can be summarized
            # by DynArray(AnyOf(Item1, Item2, Item3, Item4)). It is a lossy transformation
            # but it will help reducing the number of permutations when the operator concat() is used.
            def simplify_many_fixed_arrays
                choice_set.each_with_index { |obj1, index1|
                    next unless FixedArray === obj1

                    choice_set.each_with_index { |obj2, index2|
                        break if index2 >= index1
                        next unless FixedArray === obj2

                        return AnyOf.canonicalized(choice_set - [obj1, obj2] + [
                            DynArray.new(AnyOf.new(obj1.items + obj2.items))
                        ])
                    }
                }

                nil
            end

            # We can completely get rid of the AnyOf element of there is only one possible schema.
            def simplify_single
                choice_set.size == 1 ? choice_set.first : nil
            end

            # AnyOf[anything, string, number...] always collapse to anything.
            def simplify_anything
                choice_set.include?(Anything.instance) ? Anything.instance : nil
            end

            # AnyOf[true, false] is just boolean
            def simplify_boolean
                return unless choice_set.include?(Primitive::TRUE) && choice_set.include?(Primitive::FALSE)
                AnyOf.canonicalized(choice_set - [Primitive::TRUE, Primitive::FALSE] + [Typed::BOOLEAN])
            end

            # AnyOf[string, 'a string instance', 'another string'] is just string
            # AnyOf[boolean, true, false] is just boolean
            # AnyOf[number, 2, 3.1] is just number
            # AnyOf[integer, 2, 1] is just integer
            def simplify_typed_and_static
                choice_set.each do |typed|
                    next unless Typed === typed
                    instances = choice_set.select { |instance|
                        Primitive === instance && typed.classes.any? { |clazz| clazz === instance.value }
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
                fixed_arrays = choice_set.select { |s| FixedArray === s && s.items.uniq.size == 1 }
                return if fixed_arrays.empty?

                choice_set.each do |dyn|
                    next unless DynArray === dyn
                    fixed_arrays.each do |fixed|
                        new_dyn = DynArray.new(dyn.item)
                        return AnyOf.canonicalized(choice_set - [fixed, dyn] + [new_dyn]) if dyn.item == fixed.items.first
                    end
                end

                nil
            end

            # Merge all objects together. This is a lossy simplification, but it will greatly reduce the size
            # of the generated schema. On top of that, when the JSON-Schema is translated into Typescript, it produces
            # a much more workable type definition (union of anonymous object types is not practical to use)
            def simplify_merge_objects
                choice_set.each_with_index { |obj1, index1|
                    next unless Object === obj1

                    choice_set.each_with_index { |obj2, index2|
                        break if index2 >= index1
                        next unless Object === obj2

                        obj1props = obj1.property_set.map { |p| [p.name, p] }.to_h
                        obj2props = obj2.property_set.map { |p| [p.name, p] }.to_h

                        # Try to detect a discrimitive property (inspired from Typescript's discriminative union),
                        # We will abort the merging process if there is one
                        next if obj1props.any? { |name, p1|
                            p2 = obj2props[name]
                            next name if p2 && Primitive === p2.value &&
                                    Primitive === p1.value &&
                                    p1.value.value != p2.value.value
                        }

                        new_properties = (obj1props.keys + obj2props.keys).uniq.map { |name|
                            p1 = obj1props[name]
                            p2 = obj2props[name]

                            Object::Property.new(
                                name,
                                AnyOf.canonicalized([p1&.value, p2&.value].compact),
                                p1&.required && p2&.required || false
                            )
                        }

                        new_obj = Object.new(new_properties, obj1.additional || obj2.additional)
                        return AnyOf.canonicalized(choice_set - [obj1, obj2] + [new_obj])
                    }
                }

                nil
            end

            # Push down the AnyOf to the item if all outputs are of type DynArray
            def simplify_push_down_dyn_array
                choice_set.each_with_index { |arr1, index1|
                    next unless DynArray === arr1
                    choice_set.each_with_index { |arr2, index2|
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
