require 'babl/schema'
require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Switch < Utils::Value.new(:nodes)
            def dependencies
                (nodes.values + nodes.keys).map(&:dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                (nodes.values + nodes.keys).map(&:pinned_dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                Schema::AnyOf.canonicalized(nodes.values.map(&:schema))
            end

            def render(ctx)
                nodes.each { |cond, value| return value.render(ctx) if cond.render(ctx) }
                raise Errors::RenderingError, 'A least one switch() condition must be taken'
            end
        end
    end
end
