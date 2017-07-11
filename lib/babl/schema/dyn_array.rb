require 'values'

module Babl
    module Schema
        class DynArray < Value.new(:item, :nullable)
            def json
                { type: nullable ? %w[array null] : 'array', items: item.json }
            end
        end
    end
end
