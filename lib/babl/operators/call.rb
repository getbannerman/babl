module Babl
    module Operators
        module Call
            module DSL
                # Interpret whatever is passed to this method as BABL template. It is idempotent.
                def call(*args, &block)
                    return with(*args, &block) unless block.nil?
                    raise ::Babl::InvalidTemplateError, 'call() expects exactly 1 argument (unless block)' unless args.size == 1

                    arg = args.first

                    case arg
                    when self.class then self.class.new(builder.wrap { |bound| arg.builder.bind(bound) })
                    when ::Symbol then nav(arg)
                    when ::Proc then call(&arg)
                    when ::Hash then object(**arg.map { |k, v| [k.to_s.to_sym, v] }.to_h)
                    when ::Array then array(*arg)
                    when ::String, ::Numeric, ::NilClass, ::TrueClass, ::FalseClass then static(arg)
                    else raise ::Babl::InvalidTemplateError, "call() received invalid argument: #{arg}"
                    end
                end
            end
        end
    end
end
