# frozen_string_literal: true
require 'babl/schema'
require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Each < Utils::Value.new(:node)
            memoize def dependencies
                node_deps = node.dependencies
                child_deps = node_deps.reject { |key, _| key == Parent::PARENT_MARKER }

                Babl::Utils::Hash.deep_merge(
                    node_deps[Parent::PARENT_MARKER] || Utils::Hash::EMPTY,
                    __each__: child_deps
                )
            end

            memoize def schema
                Schema::DynArray.new(node.schema)
            end

            memoize def pinned_dependencies
                node.pinned_dependencies
            end

            memoize def optimize
                optimized = node.optimize
                optimized.equal?(node) ? self : Each.new(node.optimize)
            end

            def render(frame)
                collection = frame.object
                unless Enumerable === collection
                    raise Errors::RenderingError, "Not enumerable : #{collection.inspect}\n#{frame.formatted_stack}"
                end

                collection.map.with_index do |value, idx|
                    frame.move_forward(value, idx) do |new_frame|
                        node.render(new_frame)
                    end
                end
            end
        end
    end
end
