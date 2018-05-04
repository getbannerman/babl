# frozen_string_literal: true
require 'babl/utils'
require 'babl/schema'
require 'babl/nodes/terminal_value'
require 'singleton'

module Babl
    module Nodes
        module Typed
            class Base
                include Singleton

                def dependencies
                    Utils::Hash::EMPTY
                end

                def pinned_dependencies
                    Utils::Hash::EMPTY
                end

                def optimize
                    self
                end
            end

            class String < Base
                def schema
                    Schema::Typed::STRING
                end

                def render(frame)
                    value = frame.object
                    return value if ::String === value
                    return value.to_s if ::Symbol === value

                    raise Errors::RenderingError,
                        "Expected a string, got #{value.inspect}\n#{frame.formatted_stack}"
                end
            end

            class Integer < Base
                def schema
                    Schema::Typed::INTEGER
                end

                def render(frame)
                    value = frame.object
                    return value if ::Integer === value

                    raise Errors::RenderingError,
                        "Expected an integer, got #{value.inspect}\n#{frame.formatted_stack}"
                end
            end

            class Number < Base
                def schema
                    Schema::Typed::NUMBER
                end

                def render(frame)
                    value = frame.object
                    return value if ::Integer === value
                    return value.to_f if ::Numeric === value

                    raise Errors::RenderingError,
                        "Expected a number, got #{value.inspect}\n#{frame.formatted_stack}"
                end
            end

            class Boolean < Base
                def schema
                    Schema::Typed::BOOLEAN
                end

                def render(frame)
                    value = frame.object
                    return value if true == value || false == value

                    raise Errors::RenderingError,
                        "Expected a boolean, got #{value.inspect}\n#{frame.formatted_stack}"
                end
            end
        end
    end
end
