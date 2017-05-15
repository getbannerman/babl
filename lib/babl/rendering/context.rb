module Babl
    module Rendering
        # The rendering context stores the 'current' object.
        # Additionally, the context also:
        # - Keep a reference to the parent context, in order to implement the parent operation (ParentNode)
        # - Keep a reference to all pinned contexts, in order to goto a pinned context at any time (GotoPinNode)
        #
        # It is important to keep this object as small as possible, since an instance is created each time
        # we navigate into a property.
        class Context
            attr_reader :key, :object, :parent, :pins

            def initialize(object, key = nil, parent = nil, pins = nil)
                @key = key
                @object = object
                @parent = parent
                @pins = pins
            end

            # Standard navigation (enter into property)
            def move_forward(new_object, key)
                Context.new(new_object, key, self, pins)
            end

            # Go back to parent
            def move_backward
                raise Babl::RenderingError, 'There is no parent element' unless parent
                Context.new(parent.object, parent.key, parent.parent, pins)
            end

            # Go to a pinned context
            def goto_pin(ref)
                pin = pins&.[](ref)
                raise Babl::RenderingError, 'Pin reference cannot be used here' unless pin
                Context.new(pin.object, pin.key, pin.parent, (pin.pins || {}).merge(pins))
            end

            # Associate a pin to current context
            def create_pin(ref)
                Context.new(object, key, parent, (pins || {}).merge(ref => self))
            end

            # Wrapper around #move_forward navigating into the return value of
            # the block. However, if an error occurs, it is wrapped in a
            # Babl::RenderingError and the navigation stack trace is added
            # to the error message.
            def move_forward_block(key)
                move_forward(yield, key)
            rescue StandardError => e
                stack_trace = ([:__root__] + stack + [key]).join('.')
                raise Babl::RenderingError, "#{e.message}\nBABL @ #{stack_trace}", e.backtrace
            end

            # Return an array containing the navigation history
            def stack
                (parent ? parent.stack : []) + [key].compact
            end
        end
    end
end
