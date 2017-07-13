require 'values'

module Babl
    module Schema
        class Typed < ::Value.new(:type)
            INTEGER = new('integer')
            BOOLEAN = new('boolean')
            NUMBER = new('number')
            STRING = new('string')

            def json
                { type: type }
            end
        end
    end
end
