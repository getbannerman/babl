# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Parent < Utils::Value.new(:node)
            PARENT_MARKER = Utils::Ref.new

            class Verifier < Utils::Value.new(:node)
                def dependencies
                    deps = node.dependencies
                    raise Errors::InvalidTemplate, 'Out of context parent dependency' if deps.key? PARENT_MARKER
                    deps
                end

                def schema
                    node.schema
                end

                def pinned_dependencies
                    node.pinned_dependencies
                end

                def render(context, frame)
                    node.render(context, frame)
                end

                def optimize
                    Verifier.new(node.optimize)
                end
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def dependencies
                { PARENT_MARKER => node.dependencies }
            end

            def render(context, frame)
                context.move_backward(frame) do |new_frame|
                    node.render(context, new_frame)
                end
            end

            def optimize
                optimized = node.optimize
                Constant === optimized ? optimized : Parent.new(optimized)
            end
        end
    end
end
