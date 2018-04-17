# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'
require 'babl/nodes/parent'

module Babl
    module Nodes
        class Nav < Utils::Value.new(:property, :node)
            def dependencies
                node_deps = node.dependencies
                child_deps = node.dependencies.reject { |key, _| key == Parent::PARENT_MARKER }

                Babl::Utils::Hash.deep_merge(
                    node_deps[Parent::PARENT_MARKER] || Utils::Hash::EMPTY,
                    property => child_deps
                )
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def render(context, frame)
                value = begin
                    object = frame.object
                    ::Hash === object ? object.fetch(property) : object.send(property)
                rescue StandardError => e
                    raise Errors::RenderingError, "#{e.message}\n" + context.formatted_stack(frame, property), e.backtrace
                end

                context.move_forward(frame, value, property) do |new_frame|
                    node.render(context, new_frame)
                end
            end

            def optimize
                optimized = node.optimize
                return optimized if Constant === optimized
                return optimized.node if Parent === optimized
                Nav.new(property, optimized)
            end
        end
    end
end
