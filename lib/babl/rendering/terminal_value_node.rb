require 'singleton'

module Babl
    module Rendering
        # A TerminalValueNode node is always implicitely added to the end of the
        # chain during compilation. It basically ensures that the output contains only
        # primitives, arrays and hashes.
        class TerminalValueNode
            include Singleton

            def documentation
                :__value__
            end

            def dependencies
                {}
            end

            def pinned_dependencies
                {}
            end

            def render(ctx)
                render_object(ctx.object)
            end

            def render_object(obj)
                case obj
                when String, Numeric, NilClass, TrueClass, FalseClass then obj
                when Hash then render_hash(obj)
                when Array then render_array(obj)
                else raise Babl::RenderingError, "Only primitives can be serialized: #{obj}"
                end
            end

            private

            def render_array(array)
                array.map { |obj| render_object(obj) }
            end

            def render_hash(hash)
                hash.map { |k, v| [render_key(k), render_object(v)] }.to_h
            end

            def render_key(key)
                case key
                when Symbol, String, Numeric, NilClass, TrueClass, FalseClass then :"#{key}"
                else raise Babl::RenderingError, "Invalid key for JSON object: #{obj}"
                end
            end
        end
    end
end
