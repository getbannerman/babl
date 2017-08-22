# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'
require 'babl/schema'

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

            def self.build(nodes)
                return new(nodes) if nodes.empty?
                return nodes.first if nodes.size == 1 && Object === nodes.first

                expanded = nodes.flat_map { |node| Merge === node ? node.nodes : [node] }
                out = []
                op1 = nil
                op2 = expanded[0]
                expanded.drop(1).each do |elm|
                    op1 = op2
                    op2 = elm
                    if Object === op1 && Object === op2
                        op2 = Object.new(op1.nodes.merge(op2.nodes))
                        op1 = nil
                    end
                    out << op1 if op1
                end
                out << op2 if op2
                new(out)
            end

            private

            AS_OBJECT_MAPPING = {
                Schema::Anything.instance => Schema::Object::EMPTY_WITH_ADDITIONAL,
                Schema::Static::NULL => Schema::Object::EMPTY
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
