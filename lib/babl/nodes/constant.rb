# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'

module Babl
    module Nodes
        class Constant < Utils::Value.new(:value, :schema)
            NULL = new(nil, Schema::Primitive::NULL)
            TRUE = new(true, Schema::Primitive::TRUE)
            FALSE = new(false, Schema::Primitive::FALSE)

            def render(_frame)
                value
            end

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def optimize
                self
            end
        end
    end
end
