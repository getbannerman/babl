require 'babl/schema'
require 'babl/utils'

module Babl
    module Nodes
        class Object < Utils::Value.new(:nodes)
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
                out = {}
                nodes.each { |k, v| out[k] = v.render(ctx) }
                out
            end
        end
    end
end
