require 'singleton'
require 'babl/schema/anything'
require 'babl/errors'

module Babl
    module Nodes
        # A TerminalValue node is always implicitely added to the end of the
        # chain during compilation. It basically ensures that the output contains only
        # primitives, arrays and hashes.
        class TerminalValue
            include Singleton

            def schema
                Schema::Anything.instance
            end

            def dependencies
                {}
            end

            def pinned_dependencies
                {}
            end

            def render(ctx)
                render_object(ctx.object)
            rescue TerminalValueError => e
                raise Errors::RenderingError, "#{e.message}\n" + ctx.formatted_stack(e.babl_stack), e.backtrace
            end

            def render_object(obj, stack = [])
                case obj
                when String, Numeric, NilClass, TrueClass, FalseClass then obj
                when Hash then render_hash(obj, stack)
                when Array then render_array(obj, stack)
                else raise TerminalValueError.new("Only primitives can be serialized: #{obj}", stack)
                end
            end

            private

            def render_array(array, stack)
                array.each_with_index.map { |obj, index|
                    stack.push index
                    render_object(obj, stack)
                    stack.pop
                }
            end

            def render_hash(hash, stack)
                hash.map { |k, v|
                    key = render_key(k, stack)
                    stack.push key
                    out = [key, render_object(v, stack)]
                    stack.pop
                    out
                }.to_h
            end

            def render_key(key, stack)
                case key
                when Symbol, String, Numeric, NilClass, TrueClass, FalseClass then :"#{key}"
                else raise TerminalValueError.new("Invalid key for JSON object: #{key}", stack)
                end
            end

            class TerminalValueError < Errors::RenderingError
                attr_reader :babl_stack
                def initialize(message, babl_stack)
                    @babl_stack = babl_stack
                    super(message)
                end
            end
        end
    end
end
