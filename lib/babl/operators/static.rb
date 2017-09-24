# frozen_string_literal: true
require 'babl/nodes'
require 'babl/errors'

module Babl
    module Operators
        module Static
            module DSL
                # Create a static JSON value
                def static(val)
                    sanitized_val = Nodes::TerminalValue.instance.render_object(val)

                    case sanitized_val
                    when ::String, ::Numeric, ::NilClass, ::TrueClass, ::FalseClass
                        frozen_val = sanitized_val.dup.freeze
                        construct_terminal {
                            Nodes::Constant.new(frozen_val, Schema::Primitive.new(frozen_val))
                        }
                    else call(sanitized_val)
                    end
                rescue Errors::RenderingError => exception
                    raise Errors::InvalidTemplate, exception.message
                end
            end
        end
    end
end
