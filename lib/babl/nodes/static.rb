require 'babl/nodes/terminal_value'
require 'babl/schema/static'
require 'values'

module Babl
    module Nodes
        class Static < ::Value.new(:value)
            def schema
                Schema::Static.new(value)
            end

            def render(_ctx)
                value
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
