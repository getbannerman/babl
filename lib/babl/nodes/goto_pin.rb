# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class GotoPin < Utils::Value.new(:node, :ref)
            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Babl::Utils::Hash.deep_merge(node.pinned_dependencies, ref => node.dependencies)
            end

            def schema
                node.schema
            end

            def render(frame)
                frame.goto_pin(ref) do |new_frame|
                    node.render(new_frame)
                end
            end

            def optimize
                optimized = node.optimize
                Constant === optimized ? optimized : GotoPin.new(optimized, ref)
            end
        end
    end
end
