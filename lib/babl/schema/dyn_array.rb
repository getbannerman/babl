require 'values'

module Babl
    module Schema
        class DynArray < ::Value.new(:item)
            def json
                { type: 'array', items: item.json }
            end
        end
    end
end
