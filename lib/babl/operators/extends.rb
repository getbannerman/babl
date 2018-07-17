# frozen_string_literal: true
module Babl
    module Operators
        module Extends
            module DSL
                def extends(*args)
                    source {
                        merge(
                            *args.map { |arg|
                                case arg
                                when Template, ::Hash, ::NilClass then arg
                                else partial(arg)
                                end
                            }
                        )
                    }
                end
            end
        end
    end
end
