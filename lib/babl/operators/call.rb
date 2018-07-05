# frozen_string_literal: true
require 'babl/utils'
require 'babl/errors'

module Babl
    module Operators
        module Call
            module DSL
                # Interpret whatever is passed to this method as BABL template. It is idempotent.
                def call(*args, &block)
                    if block
                        raise Errors::InvalidTemplate, 'call() expects no argument when a block is given' unless args.empty?
                        return with(&block)
                    end

                    raise Errors::InvalidTemplate, 'call() expects exactly 1 argument (unless block)' unless args.size == 1

                    arg = args.first

                    case arg
                    when Template then self.class.new(builder.wrap { |bound| arg.builder.bind(bound) })
                    when Utils::DslProxy then call(arg.itself)
                    when ::Symbol then nav(arg)
                    when ::Proc then call(&arg)
                    when ::Hash then object(arg)
                    when ::Array then array(*arg)
                    when ::String, ::Numeric, ::NilClass, ::TrueClass, ::FalseClass then static(arg)
                    else raise Errors::InvalidTemplate, "call() received invalid argument: #{arg}"
                    end
                end
            end
        end
    end
end
