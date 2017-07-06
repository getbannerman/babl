module Babl
    module Operators
        module Extends
            module DSL
                def extends(partial_path, *args)
                    source { merge(partial(partial_path), *args) }
                end
            end
        end
    end
end
