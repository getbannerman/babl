# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Parent < Utils::Value.new(:node)
            PARENT_MARKER = Utils::Ref.new

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def dependencies
                { PARENT_MARKER => node.dependencies }
            end

            def render(frame)
                frame.move_backward do |new_frame|
                    node.render(new_frame)
                end
            end

            def optimize
                optimized = node.optimize
                Constant === optimized ? optimized : Parent.new(optimized)
            end
        end
    end
end
