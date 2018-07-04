# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Nodes
        class CreatePin < Utils::Value.new(:node, :ref)
            def render(frame)
                frame.create_pin(ref) do |new_frame|
                    node.render(new_frame)
                end
            end

            memoize def schema
                node.schema
            end

            memoize def dependencies
                Babl::Utils::Hash.deep_merge(node.dependencies, node.pinned_dependencies[ref] || Utils::Hash::EMPTY)
            end

            memoize def pinned_dependencies
                node.pinned_dependencies.reject { |k, _v| k == ref }
            end

            memoize def optimize
                optimized = node.optimize
                if !optimized.pinned_dependencies[ref]
                    optimized
                elsif optimized.equal?(node)
                    self
                else
                    CreatePin.new(optimized, ref)
                end
            end
        end
    end
end
