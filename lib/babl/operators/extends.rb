# frozen_string_literal: true
module Babl
    module Operators
        module Extends
            module DSL
                def extends(partial_path, *args)
                    source {
                        partial_template = partial(partial_path)
                        args.empty? ? partial_template : merge(partial_template, *args)
                    }
                end
            end
        end
    end
end
