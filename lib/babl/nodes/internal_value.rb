# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'
require 'singleton'

module Babl
    module Nodes
        # This Node plays a role similar to TerminalValue, but it does not perform any
        # type checking on the produced object, which is allowed to be any Ruby object,
        # including non-serializable objects.
        #
        # It is used when the output is not rendered (conditions in #switch, values passed to block in #with, ...)
        class InternalValue
            include Singleton

            # :nocov:
            def schema
                raise Errors::InvalidTemplate, 'Internal nodes cannot be documented'
            end
            # :nocov:

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def render(_context, frame)
                frame.object
            end

            def optimize
                self
            end
        end
    end
end
