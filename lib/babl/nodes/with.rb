# frozen_string_literal: true
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class With < Utils::Value.new(:node, :nodes, :block)
            def schema
                node.schema
            end

            def dependencies
                # Dependencies of 'node' are explicitely ignored
                nodes.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                (nodes + [node]).map(&:pinned_dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def renderer(ctx)
                # TODO : understandable naming convention
                var = Codegen::Variable.new
                new_ctx = ctx.move_forward(var, :__block__)
                inner_expression = node.renderer(new_ctx)
                val_exprs = nodes.map { |n| n.renderer(ctx) }

                stack_var = Codegen::Variable.new
                current_var = Codegen::Variable.new
                block_var = Codegen::Variable.new

                navigator = Codegen::Expression.new { |resolver|
                    stack = resolver.resolve(stack_var)
                    current = resolver.resolve(current_var)
                    block_var_name = resolver.resolve(block_var)

                    blk_call =
                        if block.arity.zero?
                            current + '.instance_exec(&' + block_var_name + ')'
                        else
                            block_var_name + '.call(' + val_exprs.map { |xp| resolver.resolve(xp) }.join(',') + ')'
                        end

                    <<~RUBY
                        begin
                            #{blk_call}
                        rescue ::StandardError => e
                            Babl::Nodes::Shared::ErrorHandling.raise_enriched(e, #{stack})
                        end
                    RUBY
                }

                result_var = Codegen::Local.new
                block_res = Codegen::Resource.new(block)
                stack_res = Codegen::Resource.new(new_ctx.stack)

                Codegen::Expression.new { |resolver|
                    result = resolver.resolve(result_var)
                    value = resolver.resolve navigator,
                        block_var => resolver.resolve(block_res),
                        current_var => resolver.resolve(ctx.object),
                        stack_var => resolver.resolve(stack_res)
                    call_inner = resolver.resolve(inner_expression, var => result)

                    <<-RUBY
                        #{result} = #{value}
                        #{call_inner}
                    RUBY
                }
            end

            def optimize
                optimized = node.optimize
                return optimized if Constant === optimized
                With.new(optimized, nodes.map(&:optimize), block)
            end
        end
    end
end
