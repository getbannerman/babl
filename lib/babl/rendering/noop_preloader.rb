# frozen_string_literal: true
module Babl
    module Rendering
        # BABL uses this preloader by default. It does nothing.
        class NoopPreloader
            def self.preload(data, *_params)
                data
            end
        end
    end
end
