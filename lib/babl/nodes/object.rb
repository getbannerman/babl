require 'babl/utils/hash'
require 'babl/schema/object'
require 'values'

module Babl
    module Nodes
        class Object < Value.new(:nodes)
            def dependencies
                nodes.values.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.values.map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                properties = nodes.map { |k, v| Schema::Object::Property.new(k, v.schema, true) }
                Schema::Object.new(properties, false)
            end

            def render(ctx)
                nodes.map { |k, v| [k, v.render(ctx)] }.to_h
            end
        end
    end
end
