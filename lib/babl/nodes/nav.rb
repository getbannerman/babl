# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'
require 'babl/nodes/parent'

module Babl
    module Nodes
        class Nav < Utils::Value.new(:property, :node)
            memoize def dependencies
                node_deps = node.dependencies
                child_deps = node_deps.reject { |key, _| key == Parent::PARENT_MARKER }

                Babl::Utils::Hash.deep_merge(
                    node_deps[Parent::PARENT_MARKER] || Utils::Hash::EMPTY,
                    property => child_deps
                )
            end

            memoize def schema
                node.schema
            end

            memoize def pinned_dependencies
                node.pinned_dependencies
            end

            memoize def optimize
                optimized = node.optimize
                return optimized if Constant === optimized || GotoPin === optimized
                return optimized.node if Parent === optimized
                return self if optimized.equal?(node)

                Nav.new(property, optimized)
            end

            def render(frame)
                value = begin
                            object = frame.object
                            ::Hash === object ? object.fetch(property) : object.send(property)
                        rescue StandardError => e
                            raise Errors::RenderingError, "#{e.message}\n" + frame.formatted_stack(property), e.backtrace
                        end

                frame.move_forward(value, property) do |new_frame|
                    node.render(new_frame)
                end
            end
        end
    end
end
