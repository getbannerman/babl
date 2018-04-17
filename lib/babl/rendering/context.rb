# frozen_string_literal: true
require 'babl/errors'
require 'babl/utils'

module Babl
    module Rendering
        class Context
            class Frame
                attr_accessor :object, :key, :parent, :pins

                def initialize(object = nil)
                    @object = object
                end
            end

            def initialize
                @freelist = []
            end

            def move_forward(current_frame, new_object, key)
                with_frame do |new_frame|
                    new_frame.object = new_object
                    new_frame.key = key
                    new_frame.parent = current_frame
                    new_frame.pins = current_frame.pins

                    yield new_frame
                end
            end

            def move_backward(current_frame)
                with_frame do |new_frame|
                    parent_frame = current_frame.parent
                    raise Errors::RenderingError, 'There is no parent element' unless parent_frame

                    new_frame.object = parent_frame.object
                    new_frame.parent = parent_frame.parent
                    new_frame.key = parent_frame.key
                    new_frame.pins = current_frame.pins

                    yield new_frame
                end
            end

            def goto_pin(current_frame, ref)
                current_pins = current_frame.pins || Utils::Hash::EMPTY
                pin_frame = current_pins[ref]
                raise Errors::RenderingError, 'Pin reference cannot be used here' unless pin_frame

                with_frame do |new_frame|
                    new_frame.object = pin_frame.object
                    new_frame.parent = pin_frame.parent
                    new_frame.key = pin_frame.key
                    new_frame.pins = (pin_frame.pins || Utils::Hash::EMPTY).merge(current_pins)

                    yield new_frame
                end
            end

            def create_pin(current_frame, ref)
                with_frame do |new_frame|
                    new_frame.parent = current_frame.parent
                    new_frame.object = current_frame.object
                    new_frame.key = current_frame.key
                    new_frame.pins = (current_frame.pins || Utils::Hash::EMPTY).merge(ref => new_frame)

                    yield new_frame
                end
            end

            def stack(current_frame)
                parent_frame = current_frame.parent
                (parent_frame ? stack(parent_frame) : Utils::Array::EMPTY) + [current_frame.key].compact
            end

            def formatted_stack(current_frame, *additional_stack_items)
                stack_trace = ([:__root__] + stack(current_frame) + additional_stack_items).join('.')
                "BABL @ #{stack_trace}"
            end

            private

            def with_frame
                frame = @freelist.pop || Frame.new
                yield frame
            ensure
                @freelist << frame
            end
        end
    end
end
