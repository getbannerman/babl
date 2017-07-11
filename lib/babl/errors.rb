module Babl
    module Errors
        class BablError < StandardError; end
        class InvalidTemplateError < BablError; end
        class RenderingError < BablError; end
    end
end
