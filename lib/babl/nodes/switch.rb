require 'babl/utils/hash'
require 'babl/schema/any_of'
require 'babl/errors'
require 'values'

module Babl
    module Nodes
        class Switch < ::Value.new(:nodes)
            def dependencies
                (nodes.values + nodes.keys).map(&:dependencies)
                    .reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                (nodes.values + nodes.keys).map(&:pinned_dependencies)
                    .reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                Schema::AnyOf.canonical(nodes.values.map(&:schema))
            end

            def render(ctx)
                nodes.each { |cond, value| return value.render(ctx) if cond.render(ctx) }
                raise Errors::RenderingError, 'A least one switch() condition must be taken'
            end
        end
    end
end
