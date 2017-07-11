require 'babl/nodes/static'
require 'babl/nodes/terminal_value'
require 'babl/errors'

module Babl
    module Operators
        module Static
            module DSL
                # Create a static JSON value
                def static(val)
                    case val
                    when String, Numeric, NilClass, TrueClass, FalseClass then construct_terminal { Nodes::Static.new(val) }
                    else call(Nodes::TerminalValue.instance.render_object(val))
                    end
                rescue Errors::RenderingError => exception
                    raise Errors::InvalidTemplateError, exception.message
                end
            end
        end
    end
end
