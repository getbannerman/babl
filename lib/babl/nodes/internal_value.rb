require 'singleton'
require 'babl/errors'

module Babl
    module Nodes
        # This Node plays a role similar to TerminalValue, but it does not perform any
        # type checking on the produced object, which is allowed to be any Ruby object,
        # including non-serializable objects.
        #
        # It is used when the output is not rendered (conditions in #switch, values passed to block in #with, ...)
        class InternalValue
            include Singleton

            def schema
                raise Errors::InvalidTemplate, 'Internal nodes cannot be documented'
            end

            def dependencies
                {}
            end

            def pinned_dependencies
                {}
            end

            def render(ctx)
                ctx.object
            end
        end
    end
end
