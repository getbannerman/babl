# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Parent < Utils::Value.new(:node)
            PARENT_MARKER = Utils::Ref.new

            memoize def schema
                node.schema
            end

            memoize def pinned_dependencies
                node.pinned_dependencies
            end

            memoize def dependencies
                { PARENT_MARKER => node.dependencies }
            end

            memoize def optimize
                optimized = node.optimize
                return optimized if Constant === optimized || GotoPin === optimized
                return self if optimized.equal?(node)
                Parent.new(optimized)
            end

            def render(frame)
                frame.move_backward do |new_frame|
                    node.render(new_frame)
                end
            end
        end
    end
end
