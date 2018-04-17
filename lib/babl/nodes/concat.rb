# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'
require 'babl/schema'

module Babl
    module Nodes
        class Concat < Utils::Value.new(:nodes)
            def dependencies
                nodes.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.map(&:pinned_dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                nodes.map(&:schema).reduce(Schema::FixedArray::EMPTY) { |a, b| merge_doc(a, b) }
            end

            def render(context, frame)
                out = []
                nodes.each { |node|
                    values = node.render(context, frame)
                    case values
                    when ::NilClass then nil
                    when ::Array then out.concat(values)
                    else raise Errors::RenderingError, "Only arrays can be concatenated\n" + context.formatted_stack(frame)
                    end
                }
                out
            end

            def optimize
                optimize_empty ||
                    optimize_single ||
                    optimize_concatenated_arrays ||
                    optimize_preconcat_constant ||
                    self
            end

            private

            def optimize_empty
                Constant.new(Utils::Array::EMPTY, Schema::FixedArray::EMPTY) if nodes.empty?
            end

            def optimize_single
                return unless nodes.size == 1
                optimized = nodes.first.optimize
                case
                when FixedArray === optimized
                    optimized
                when Constant === optimized
                    optimized.value.nil? ? FixedArray::EMPTY : optimized
                end
            end

            def optimize_concatenated_arrays
                optimized_nodes = nodes.map(&:optimize)
                return if optimized_nodes == nodes
                Concat.new(optimized_nodes).optimize
            end

            def optimize_preconcat_constant
                nodes.each_cons(2).each_with_index do |(obj1, obj2), idx|
                    obj1 = constant_to_array(obj1) if Constant === obj1
                    obj2 = constant_to_array(obj2) if Constant === obj2
                    next unless FixedArray === obj1 && FixedArray === obj2
                    new_nodes = nodes.dup
                    new_nodes[idx] = FixedArray.new(obj1.nodes + obj2.nodes)
                    new_nodes[idx + 1] = nil
                    return Concat.new(new_nodes.compact).optimize
                end
                nil
            end

            def constant_to_array(constant)
                case constant.schema
                when Schema::FixedArray
                    FixedArray.new(constant.schema.items.each_with_index.map { |item, index|
                        Constant.new(constant.value[index], item)
                    })
                when Schema::Primitive::NULL
                    FixedArray::EMPTY
                end
            end

            # Merging documentations from concatenated hashes is lossy, because neither JSON-Schema
            # or our internal representation of arrays is able to model that.
            def merge_doc(doc1, doc2)
                doc1 = Schema::FixedArray::EMPTY if doc1 == Schema::Primitive::NULL
                doc2 = Schema::FixedArray::EMPTY if doc2 == Schema::Primitive::NULL

                case
                when Schema::Anything === doc1 || Schema::Anything === doc2
                    Schema::DynArray.new(Schema::Anything.instance)
                when Schema::FixedArray === doc1 && Schema::FixedArray === doc2
                    Schema::FixedArray.new(doc1.items + doc2.items)
                when Schema::AnyOf === doc2
                    Schema::AnyOf.canonicalized(doc2.choice_set.map { |c| merge_doc(doc1, c) })
                when Schema::AnyOf === doc1
                    Schema::AnyOf.canonicalized(doc1.choice_set.map { |c| merge_doc(c, doc2) })
                when Schema::DynArray === doc1 && Schema::FixedArray === doc2
                    Schema::DynArray.new(Schema::AnyOf.canonicalized([doc1.item] + doc2.items))
                when Schema::FixedArray === doc1 && Schema::DynArray === doc2
                    Schema::DynArray.new(Schema::AnyOf.canonicalized(doc1.items + [doc2.item]))
                when Schema::DynArray === doc1 && Schema::DynArray === doc2
                    Schema::DynArray.new(Schema::AnyOf.canonicalized([doc1.item, doc2.item]))
                else raise Errors::InvalidTemplate, 'Only arrays can be concatenated'
                end
            end
        end
    end
end
