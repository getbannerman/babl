# frozen_string_literal: true
require 'babl/utils/value'

module Babl
    module Codegen
        class Generator
            class InlineResolver
                attr_reader :assigned_vars, :resolver

                def initialize(resolver, assigned_vars)
                    @resolver = resolver
                    @assigned_vars = assigned_vars
                end

                def resolve(val, vars = {})
                    case val
                    when Expression then resolver.resolve(val, assigned_vars.merge(vars))
                    when Variable then (assigned_vars[val] && ('(' + assigned_vars[val] + ')')) || resolver.resolve(val)
                    else resolver.resolve(val)
                    end
                end
            end

            class Resolver
                attr_reader :generator, :argument_names, :called_linked_expressions, :expr, :local_names

                def initialize(generator, expr)
                    @expr = expr
                    @generator = generator
                    @argument_names = {}
                    @called_linked_expressions = []
                    @local_names = {}
                end

                def resolve(*args)
                    case args.first
                    when Variable then variable(*args)
                    when Resource then resource(*args)
                    # TODO : do not inline if resolved more than once + ensure we are always re-resolving to
                    # account for all cases
                    when Expression then expression(*args)
                    when Local then local(*args)
                    end
                end

                def local(var)
                    local_names[var] ||= "l#{local_names.size}"
                end

                def expression(other_expr, assigned_vars = {})
                    linked_other = generator.link(other_expr)

                    if linked_other.expression && generator.allowed_inlining.include?(linked_other)
                        inline_resolver = InlineResolver.new(self, assigned_vars)
                        '(' + linked_other.expression.code.call(inline_resolver) + ')'
                    else
                        called_linked_expressions << linked_other
                        params = linked_other.inputs.map { |rv|
                            (assigned_vars[rv] && ('(' + assigned_vars[rv] + ')')) || variable(rv)
                        }.join(',')
                        linked_other.name + (params.empty? ? '' : '(' + params + ')')
                    end
                end

                def variable(var)
                    argument_names[var] ||= "v#{argument_names.size}"
                end

                def resource(res)
                    generator.resource_name(res)
                end
            end

            attr_reader :linked_expressions, :root_expression, :method_names, :evaluator_inputs,
                :resources, :allowed_inlining, :linked_root_expression

            def initialize(root_expression, *evaluator_inputs)
                @evaluator_inputs = evaluator_inputs
                @root_expression = root_expression
                @allowed_inlining = Set.new
                @method_names = {}
                @resources = {}
                @linked_expressions = {}

                # First pass: we link all expressions together without inlining.
                @linked_root_expression = link(root_expression)

                # Second pass: we have collected data about how much time each expression is used
                # so we can selectivety enable inlining when appropriate.
                loop do
                    # break
                    prev_inline_size = allowed_inlining.size
                    compute_allowed_inlining
                    # puts allowed_inlining.size
                    @linked_expressions = {}
                    @linked_root_expression = link(root_expression)
                    # break
                    break if prev_inline_size == allowed_inlining.size
                end
            end

            def compute_allowed_inlining
                # Inline expressions which are only called once
                linked_expressions.values
                    .flat_map { |le| le.called_linked_expressions.map { |called_le| [called_le, le] } }
                    .group_by { |called_le, _| called_le.name }
                    .each { |_, group|
                        next if group.size > 1
                        group.each { |called_le, _|
                            allowed_inlining << called_le
                        }
                    }

                # Inline expressions taking no parameter
                linked_expressions.values
                    .select { |le| le.inputs.empty? }
                    .each { |le| allowed_inlining << le }
            end

            def called_linked_expressions(root)
                [root] + root.called_linked_expressions.flat_map { |le| called_linked_expressions(le) }
            end

            def compile
                body = called_linked_expressions(linked_root_expression).map(&:code).uniq.join("\n")
                linked_root_expr = linked_expressions[root_expression]

                ordered_variables = linked_root_expr.inputs.map { |rv| "v#{evaluator_inputs.index(rv)}" }
                raise Errors::InvalidTemplate, 'Codegen failed' if ordered_variables.include?('v')

                body << <<~RUBY
                    def evaluate(#{Array.new(evaluator_inputs.size) { |i| "v#{i}" }.join(',')})
                        #{linked_root_expr.name}(#{ordered_variables.join(',')})
                    end
                RUBY

                # puts body

                Class.new.tap { |clazz|
                    resources.each { |k, v|
                        clazz.const_set(v, k.value)
                        # puts "#{v} = #{k.value.inspect}"
                    }

                    clazz.class_eval(body)
                }.new
            end

            def link(expr)
                return linked_expressions[expr] if linked_expressions[expr]

                resolver = Resolver.new(self, expr)
                body = expr.code.call(resolver)
                args = resolver.argument_names.values
                name = method_name(body, args)

                fle = linked_expressions.find { |_xp, le| le.code == body }&.last
                if fle
                    fle.called_linked_expressions += resolver.called_linked_expressions
                    return fle
                end

                linked_expressions[expr] = LinkedExpression.new(
                    name, resolver.argument_names.keys, expr, resolver.called_linked_expressions, <<~RUBY)
                    def #{name}(#{args.join(',')})
                    #{body}
                    end
                RUBY
            end

            def resource_name(resource)
                @resources[resource] ||= "R#{@resources.size}"
            end

            def method_name(body, args)
                @method_names[[body, args]] ||= "x#{@method_names.size}"
            end
        end
    end
end
