module Babl
    module Errors
        class Base < StandardError; end
        class InvalidTemplate < Base; end
        class RenderingError < Base; end
    end
end
