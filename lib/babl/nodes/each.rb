require 'babl/schema/dyn_array'
require 'babl/errors'
require 'values'

module Babl
    module Nodes
        class Each < Value.new(:node)
            def dependencies
                { __each__: node.dependencies }
            end

            def schema
                Schema::DynArray.new(node.schema, false)
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(ctx)
                collection = ctx.object
                unless Enumerable === collection
                    raise Errors::RenderingError, "Not enumerable : #{collection}\n#{ctx.formatted_stack}"
                end
                collection.each_with_index.map { |value, idx| node.render(ctx.move_forward(value, idx)) }
            end
        end
    end
end
