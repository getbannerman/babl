# frozen_string_literal: true
require 'babl/schema'
require 'babl/errors'
require 'babl/utils'
require 'singleton'

module Babl
    module Nodes
        # A TerminalValue node is always implicitly added to the end of the
        # chain during compilation. It basically ensures that the output contains only
        # primitives, arrays and hashes.
        class TerminalValue
            include Singleton

            def schema
                Schema::Anything.instance
            end

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def render(frame)
                render_object(frame.object)
            rescue TerminalValueError => e
                raise Errors::RenderingError, "#{e.message}\n" + frame.formatted_stack(e.babl_stack), e.backtrace
            end

            def render_object(obj, stack = nil)
                case obj
                when ::String, ::Integer, ::NilClass, ::TrueClass, ::FalseClass then obj
                when ::Numeric then obj.to_f
                when ::Symbol then obj.to_s
                when ::Hash then render_hash(obj, stack || [])
                when ::Array then render_array(obj, stack || [])
                else raise TerminalValueError.new("Only primitives can be serialized: #{obj.inspect}", stack || [])
                end
            end

            def optimize
                self
            end

            private

            def render_array(array, stack)
                array.each_with_index.map { |obj, index|
                    stack.push index
                    out = render_object(obj, stack)
                    stack.pop
                    out
                }
            end

            def render_hash(hash, stack)
                out = {}
                hash.each { |k, v|
                    key = render_key(k, stack)
                    stack.push key
                    out[key] = render_object(v, stack)
                    stack.pop
                }
                out
            end

            def render_key(key, stack)
                case key
                when ::Symbol then key
                when ::String then key.to_sym
                # rubocop:disable Lint/BooleanSymbol
                when ::TrueClass then :true
                when ::FalseClass then :false
                # rubocop:enable Lint/BooleanSymbol
                when ::Numeric, ::NilClass then :"#{key}"
                else raise TerminalValueError.new("Invalid key for JSON object: #{key.inspect}", stack)
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
