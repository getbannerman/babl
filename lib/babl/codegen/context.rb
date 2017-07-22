# frozen_string_literal: true
require 'babl/errors'

module Babl
    module Codegen
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
                raise Errors::InvalidTemplate, 'There is no parent element' unless parent
                Context.new(parent.object, parent.key, parent.parent, pins)
            end

            # Go to a pinned context
            def goto_pin(ref)
                pin = pins&.[](ref)
                raise Errors::InvalidTemplate, 'Pin reference cannot be used here' unless pin
                Context.new(pin.object, pin.key, pin.parent, (pin.pins || {}).merge(pins))
            end

            # Associate a pin to current context
            def create_pin(ref)
                Context.new(object, key, parent, (pins || {}).merge(ref => self))
            end

            def formatted_stack
                stack_trace = ([:__root__] + stack).join('.')
                "BABL @ #{stack_trace}"
            end

            # Return an array containing the navigation history
            def stack
                (parent ? parent.stack : []) + [key].compact
            end
        end
    end
end
