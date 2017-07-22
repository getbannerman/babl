# frozen_string_literal: true
require 'babl/schema'
require 'babl/errors'
require 'babl/utils'

module Babl
    module Nodes
        class Each < Utils::Value.new(:node)
            def dependencies
                { __each__: node.dependencies }
            end

            def schema
                Schema::DynArray.new(node.schema)
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def renderer(ctx)
                it_var = Codegen::Variable.new
                stack_var = Codegen::Variable.new
                stack_res = Codegen::Resource.new(ctx.stack)
                inner_expression = node.renderer(ctx.move_forward(it_var, :'#'))

                ensure_enumerable = Codegen::Expression.new { |resolver|
                    val = resolver.resolve(ctx.object)
                    stack = resolver.resolve(stack_var)
                    <<~RUBY
                        unless ::Enumerable === #{val}
                            Babl::Nodes::Shared::ErrorHandling.raise_message(
                                'Not enumerable : ' + #{val}.inspect + "\\n",
                                #{stack}
                            )
                        end
                        #{val}
                    RUBY
                }

                local_var = Codegen::Local.new

                Codegen::Expression.new { |resolver|
                    local = resolver.resolve(local_var)
                    array = resolver.resolve(ensure_enumerable, stack_var => resolver.resolve(stack_res))
                    inner = resolver.resolve(inner_expression, it_var => local)

                    "#{array}.map { |#{local}| #{inner} }"
                }
            end

            def optimize
                Each.new(node.optimize)
            end
        end
    end
end
