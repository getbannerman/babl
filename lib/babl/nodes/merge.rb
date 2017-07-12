require 'babl/utils/hash'
require 'babl/errors'
require 'values'

module Babl
    module Nodes
        class Merge < Value.new(:nodes)
            def initialize(nodes)
                super
            end

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

            # Merge two documentations together
            def merge_doc(doc1, doc2)
                doc1 = Schema::Object::EMPTY if Schema::Static::NULL == doc1
                doc2 = Schema::Object::EMPTY if Schema::Static::NULL == doc2

                case
                when Schema::AnyOf === doc1 || Schema::AnyOf === doc2
                    merge_extended(doc1, doc2)
                when Schema::Object === doc1 && Schema::Object === doc2
                    merge_object(doc1, doc2)
                when Schema::Object === doc1 && Schema::Anything === doc2
                    merge_object(doc1, Schema::Object::EMPTY_WITH_ADDITIONAL)
                when Schema::Anything === doc1 && Schema::Object === doc2
                    merge_object(Schema::Object::EMPTY_WITH_ADDITIONAL, doc2)
                else
                    raise Errors::InvalidTemplateError, 'Only objects can be merged'
                end
            end

            # Merge two documention when Schema::AnyOf is involved either
            # on left, right or both sides.
            def merge_extended(doc1, doc2)
                # Ensure doc1 & doc2 are both Schema::AnyOf
                choices1 = Schema::AnyOf === doc1 ? doc1.choices : [doc1]
                choices2 = Schema::AnyOf === doc2 ? doc2.choices : [doc2]

                # Generate all possible combinations
                all_docs = choices1.product(choices2)
                    .map { |choice1, choice2| merge_doc(choice1, choice2) }

                # Analyze each property accross all combination to
                # generate a Schema::Object::Property filled with
                # accurate information.
                final_properties = all_docs.flat_map(&:properties)
                    .group_by(&:name)
                    .map do |name, properties|
                    Schema::Object::Property.new(
                        name,
                        Schema::AnyOf.canonical(properties.map(&:value)),
                        properties.size == all_docs.size && properties.all?(&:required)
                    )
                end

                # Generate the final Schema::Object
                Schema::Object.new(final_properties, all_docs.any?(&:additional))
            end

            # Merge two Schema::Object
            def merge_object(doc1, doc2)
                additional = doc1.additional || doc2.additional

                properties = (
                    doc1.properties.map { |property| doc2.additional ? allow_anything(property) : property } +
                    doc2.properties
                ).each_with_object({}) { |property, acc| acc[property.name] = property }.values

                Schema::Object.new(properties, additional)
            end

            # Rewrite a property to allow Schema::Anything as value
            def allow_anything(property)
                Schema::Object::Property.new(
                    property.name,
                    Schema::AnyOf.canonical([property.value, Schema::Anything.instance]),
                    property.required
                )
            end
        end
    end
end
