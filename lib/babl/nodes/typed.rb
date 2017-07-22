# frozen_string_literal: true
require 'babl/utils'
require 'babl/schema'
require 'babl/nodes/terminal_value'

module Babl
    module Nodes
        class Typed < Utils::Value.new(:schema)
            BOOLEAN = new(Schema::Typed::BOOLEAN)
            INTEGER = new(Schema::Typed::INTEGER)
            NUMBER = new(Schema::Typed::NUMBER)
            STRING = new(Schema::Typed::STRING)

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def renderer(ctx)
                stack_var = Codegen::Variable.new
                value_var = Codegen::Variable.new

                raiser = Codegen::Expression.new { |resolver|
                    stack = resolver.resolve(stack_var)
                    value = resolver.resolve(value_var)

                    <<~RUBY
                        Babl::Nodes::Shared::ErrorHandling.raise_message(
                            'Expected type #{schema.type}:' + #{value}.inspect, #{stack}
                        )
                    RUBY
                }

                tester = Codegen::Expression.new { |resolver|
                    value = resolver.resolve(value_var)
                    test = schema.classes.map { |cl| "::#{cl.name} === #{value}" }.join('||')
                    # TODO : BigDecimal handling
                    "#{test} ? #{value} : #{resolver.resolve(raiser)}"
                }

                stack_res = Codegen::Resource.new(ctx.stack)

                Codegen::Expression.new { |resolver|
                    resolver.resolve tester,
                        stack_var => resolver.resolve(stack_res),
                        value_var => resolver.resolve(ctx.object)
                }
            end

            def optimize
                self
            end
        end
    end
end
