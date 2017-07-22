# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'
require 'babl/nodes/parent'

module Babl
    module Nodes
        class Nav < Utils::Value.new(:property, :node)
            def dependencies
                { property => node.dependencies }
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def renderer(ctx)
                var = Codegen::Variable.new
                new_ctx = ctx.move_forward(var, property)
                inner_expression = node.renderer(new_ctx)

                stack_var = Codegen::Variable.new
                current_var = Codegen::Variable.new
                property_var = Codegen::Variable.new

                navigator = Codegen::Expression.new { |resolver|
                    stack = resolver.resolve(stack_var)
                    current = resolver.resolve(current_var)
                    property = resolver.resolve(property_var)

                    <<~RUBY
                        begin
                            ::Hash === #{current} ? #{current}.fetch(#{property}) : #{current}.__send__(#{property})
                        rescue ::StandardError => e
                            Babl::Nodes::Shared::ErrorHandling.raise_enriched(e, #{stack})
                        end
                    RUBY
                }

                stack_res = Codegen::Resource.new(new_ctx.stack)
                local_var = Codegen::Local.new

                Codegen::Expression.new { |resolver|
                    local = resolver.resolve(local_var)

                    navigated = resolver.resolve(
                        navigator,
                        stack_var => resolver.resolve(stack_res),
                        current_var => resolver.resolve(ctx.object),
                        property_var => property.inspect
                    )

                    call_inner = resolver.resolve(
                        inner_expression,
                        var => local
                    )

                    "begin; #{local} = #{navigated}; #{call_inner}; end"
                }
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
