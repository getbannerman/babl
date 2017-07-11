require 'singleton'

module Babl
    module Schema
        class Anything
            include Singleton

            def json
                {}
            end
        end
    end
end
