# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'

module Babl
    module Rendering
        class Context
            attr_accessor :object, :key, :parent, :pins, :freelist

            def initialize(freelist = [])
                @freelist = freelist
            end

            def move_forward(new_object, key)
                new_frame = @freelist.pop || Context.new(freelist)

                new_frame.object = new_object
                new_frame.key = key
                new_frame.parent = self
                new_frame.pins = pins

                yield new_frame
            ensure
                @freelist << new_frame
            end

            def move_backward
                new_frame = @freelist.pop || Context.new(freelist)

                parent_frame = parent
                raise Errors::RenderingError, 'There is no parent element' unless parent_frame

                new_frame.object = parent_frame.object
                new_frame.parent = parent_frame.parent
                new_frame.key = parent_frame.key
                new_frame.pins = pins

                yield new_frame
            ensure
                @freelist << new_frame
            end

            def goto_pin(ref)
                current_pins = pins || Utils::Hash::EMPTY
                pin_frame = current_pins[ref]
                raise Errors::RenderingError, 'Pin reference cannot be used here' unless pin_frame

                new_frame = @freelist.pop || Context.new(freelist)

                new_frame.object = pin_frame.object
                new_frame.parent = pin_frame.parent
                new_frame.key = pin_frame.key
                new_frame.pins = (pin_frame.pins || Utils::Hash::EMPTY).merge(current_pins)

                yield new_frame
            ensure
                @freelist << new_frame
            end

            def create_pin(ref)
                new_frame = @freelist.pop || Context.new(freelist)

                new_frame.parent = parent
                new_frame.object = object
                new_frame.key = key
                new_frame.pins = (pins || Utils::Hash::EMPTY).merge(ref => new_frame)

                yield new_frame
            ensure
                @freelist << new_frame
            end

            def stack
                parent_frame = parent
                (parent_frame ? parent_frame.stack : Utils::Array::EMPTY) + [key].compact
            end

            def formatted_stack(*additional_stack_items)
                stack_trace = ([:__root__] + stack + additional_stack_items).join('.')
                "BABL @ #{stack_trace}"
            end
        end
    end
end
