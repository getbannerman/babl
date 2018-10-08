# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class GotoPin < Utils::Value.new(:node, :ref)
            memoize def dependencies
                Utils::Hash::EMPTY
            end

            memoize def pinned_dependencies
                Babl::Utils::Hash.deep_merge([node.pinned_dependencies, ref => node.dependencies])
            end

            memoize def schema
                node.schema
            end

            memoize def optimize
                optimized = node.optimize
                if Constant === optimized
                    optimized
                elsif optimized.equal?(node)
                    self
                else
                    GotoPin.new(optimized, ref)
                end
            end

            def render(frame)
                frame.goto_pin(ref) do |new_frame|
                    node.render(new_frame)
                end
            end
        end
    end
end
