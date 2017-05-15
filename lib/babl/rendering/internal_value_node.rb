require 'singleton'

module Babl
    module Rendering
        # This Node plays a role similar to TerminalValueNode, but it does not perform any
        # type checking on the produced object, which is allowed to be any Ruby object,
        # including non-serializable objects.
        #
        # It is used when the output is not rendered (conditions in #switch, values passed to block in #with, ...)
        class InternalValueNode
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
                ctx.object
            end
        end
    end
end
