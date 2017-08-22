# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'

module Babl
    module Nodes
        class Static < Utils::Value.new(:value)
            def schema
                case value
                when ::NilClass then Schema::Static::NULL
                when ::TrueClass then Schema::Static::TRUE
                when ::FalseClass then Schema::Static::FALSE
                else Schema::Static.new(value)
                end
            end

            def render(_ctx)
                value
            end

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            private

            def generate_doc
            end
        end
    end
end
