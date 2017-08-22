# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Schema
        class DynArray < Utils::Value.new(:item)
            def json
                { type: 'array', items: item.json }
            end
        end
    end
end
