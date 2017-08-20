require 'babl/errors'
require 'babl/utils'
require 'babl/schema'

module Babl
    module Nodes
        class Merge < Utils::Value.new(:nodes)
            def dependencies
                nodes.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
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
                    Schema::AnyOf.canonicalized(doc1.choices.map { |c| merge_doc(c, doc2) })
                when Schema::AnyOf === doc2
                    Schema::AnyOf.canonicalized(doc2.choices.map { |c| merge_doc(doc1, c) })
                when Schema::Object === doc1 && Schema::Object === doc2
                    merge_object(doc1, doc2)
                else raise Errors::InvalidTemplate, 'Only objects can be merged'
                end
            end

            # Merge two Schema::Object
            def merge_object(doc1, doc2)
                additional = doc1.additional || doc2.additional

                properties = (
                    doc1.properties.map { |property| doc2.additional ? anything_property(property) : property } +
                    doc2.properties
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
