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
                    simplify_merge_objects ||
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

            # Merge all objects together. This is the only lossy simplification, but it will greatly reduce the size
            # of the generated schema. On top of that, when the JSON-Schema is translated into Typescript, it produces
            # a much more workable type definition (union of anonymous object types is not practical to use)
            def simplify_merge_objects
                choices.each_with_index { |obj1, index1|
                    next unless Object === obj1

                    choices.each_with_index { |obj2, index2|
                        break if index2 >= index1
                        next unless Object === obj2

                        obj1props = obj1.properties.map { |p| [p.name, p] }.to_h
                        obj2props = obj2.properties.map { |p| [p.name, p] }.to_h

                        # Do not merge properties unless a keyset is almost a subset of the other
                        next unless (obj1props.keys.to_set - obj2props.keys).size <= 1 ||
                                (obj2props.keys.to_set - obj1props.keys).size <= 1

                        # Try to detect a discrimitive property (inspired from Typescript's discriminative union),
                        # We will abort the merging process unless all the other properties are exactly the same.
                        discriminator = obj1props.find { |name, p1|
                            p2 = obj2props[name]
                            next name if p2 && Static === p2.value && Static === p1.value && p1.value.value != p2.value.value
                        }&.first

                        new_properties = (obj1props.keys + obj2props.keys).uniq.map { |name|
                            p1 = obj1props[name]
                            p2 = obj2props[name]

                            break if discriminator && discriminator != name && p1 != p2

                            Object::Property.new(
                                name,
                                AnyOf.canonicalized([p1&.value, p2&.value].compact),
                                p1&.required && p2&.required || false
                            )
                        }

                        next unless new_properties
                        new_obj = Object.new(new_properties, obj1.additional || obj2.additional)
                        return AnyOf.canonicalized(choice_set - [obj1, obj2] + [new_obj])
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
