# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'
require 'babl/schema'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class Merge < Utils::Value.new(:nodes)
            def dependencies
                nodes.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.map(&:pinned_dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                nodes.map(&:schema).reduce(Schema::Object::EMPTY) { |a, b| merge_doc(a, b) }
            end

            def render(ctx)
                nodes.map { |node| node.render(ctx) }.compact.reduce({}) { |acc, val|
                    raise Errors::RenderingError, "Only objects can be merged\n" + ctx.formatted_stack unless ::Hash === val
                    acc.merge!(val)
                }
            end

            def optimize
                optimize_empty ||
                    optimize_single ||
                    optimize_merged_objects ||
                    optimize_nested_merges ||
                    optimize_premergeable_objects ||
                    self
            end

            private

            def optimize_empty
                Constant.new({}, Schema::Object::EMPTY) if nodes.empty?
            end

            def optimize_single
                return unless nodes.size == 1
                optimized = nodes.first.optimize
                case
                when Object === optimized then optimized
                when Constant === optimized && optimized.value.nil? then Object::EMPTY
                end
            end

            def optimize_merged_objects
                optimized_nodes = nodes.map(&:optimize)
                optimized_nodes == nodes ? nil : Merge.new(optimized_nodes).optimize
            end

            def optimize_nested_merges
                return unless nodes.any? { |node| Merge === node }
                Merge.new(nodes.flat_map { |node| Merge === node ? node.nodes : [node] }).optimize
            end

            def optimize_premergeable_objects
                nodes.each_cons(2).each_with_index do |(obj1, obj2), idx|
                    obj1 = constant_to_object(obj1) if Constant === obj1
                    obj2 = constant_to_object(obj2) if Constant === obj2

                    if Object === obj1 && Object === obj2
                        new_nodes = nodes.dup
                        new_nodes[idx] = Object.new(obj1.nodes.merge(obj2.nodes))
                        new_nodes[idx + 1] = nil
                        return Merge.new(new_nodes.compact).optimize
                    end
                end
                nil
            end

            def constant_to_object(constant)
                case constant.schema
                when Schema::Object
                    Object.new(constant.schema.property_set.map { |property|
                        [property.name, Constant.new(constant.value[property.name], property.value)]
                    }.to_h)
                end
            end

            AS_OBJECT_MAPPING = {
                Schema::Anything.instance => Schema::Object::EMPTY_WITH_ADDITIONAL,
                Schema::Primitive::NULL => Schema::Object::EMPTY
            }

            # Merge two documentations together
            def merge_doc(doc1, doc2)
                doc1 = AS_OBJECT_MAPPING[doc1] || doc1
                doc2 = AS_OBJECT_MAPPING[doc2] || doc2

                case
                when Schema::AnyOf === doc1
                    Schema::AnyOf.canonicalized(doc1.choice_set.map { |c| merge_doc(c, doc2) })
                when Schema::AnyOf === doc2
                    Schema::AnyOf.canonicalized(doc2.choice_set.map { |c| merge_doc(doc1, c) })
                when Schema::Object === doc1 && Schema::Object === doc2
                    merge_object(doc1, doc2)
                else raise Errors::InvalidTemplate, 'Only objects can be merged'
                end
            end

            # Merge two Schema::Object
            def merge_object(doc1, doc2)
                additional = doc1.additional || doc2.additional

                properties = (
                    doc1.property_set.map { |property| doc2.additional ? anything_property(property) : property } +
                    doc2.property_set.to_a
                ).each_with_object({}) { |property, acc| acc[property.name] = property }.values

                Schema::Object.new(properties, additional)
            end

            # Rewrite a property to allow Schema::Anything as value
            def anything_property(property)
                Schema::Object::Property.new(property.name, Schema::Anything.instance, property.required)
            end
        end
    end
end
