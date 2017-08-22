# frozen_string_literal: true
require 'babl/nodes'
require 'babl/errors'

module Babl
    module Operators
        module Static
            module DSL
                # Create a static JSON value
                def static(val)
                    case val
                    when ::String, ::Numeric, ::NilClass, ::TrueClass, ::FalseClass
                        construct_terminal { Nodes::Static.new(val) }
                    else call(Nodes::TerminalValue.instance.render_object(val))
                    end
                rescue Errors::RenderingError => exception
                    raise Errors::InvalidTemplate, exception.message
                end
            end
        end
    end
end
