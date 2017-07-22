require 'babl/schema'
require 'babl/utils'

module Babl
    module Nodes
        class Static < Utils::Value.new(:value)
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
