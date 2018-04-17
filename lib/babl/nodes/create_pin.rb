# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Nodes
        class CreatePin < Utils::Value.new(:node, :ref)
            def render(context, frame)
                context.create_pin(frame, ref) do |new_frame|
                    node.render(context, new_frame)
                end
            end

            def schema
                node.schema
            end

            def dependencies
                Babl::Utils::Hash.deep_merge(node.dependencies, node.pinned_dependencies[ref] || Utils::Hash::EMPTY)
            end

            def pinned_dependencies
                node.pinned_dependencies.reject { |k, _v| k == ref }
            end

            def optimize
                optimized = node.optimize
                optimized.pinned_dependencies[ref] ? CreatePin.new(optimized, ref) : optimized
            end
        end
    end
end
