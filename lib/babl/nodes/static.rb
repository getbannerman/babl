require 'babl/nodes/terminal_value'
require 'babl/schema/static'
require 'values'

module Babl
    module Nodes
        class Static < Value.new(:serialized_value)
            def initialize(value)
                super(value)
            end

            def schema
                Schema::Static.new(serialized_value)
            end

            def render(_ctx)
                serialized_value
            end

            def dependencies
                {}
            end

            def pinned_dependencies
                {}
            end

            private

            def generate_doc
            end
        end
    end
end
