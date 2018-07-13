# frozen_string_literal: true
module Babl
    module Operators
        module Extends
            module DSL
                def extends(*partial_paths, extended_with)
                    source {
                        merge(
                            *partial_paths.map { |path| partial(path) },
                            extended_with
                        )
                    }
                end
            end
        end
    end
end
