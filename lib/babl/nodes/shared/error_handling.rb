# frozen_string_literal: true
module Babl
    module Nodes
        module Shared
            module ErrorHandling
                class << self
                    def raise_enriched(exception, stack)
                        raise Errors::RenderingError,
                            "#{exception.message}\nBABL @ #{([:__root__] + stack).join('.')}",
                            exception.backtrace
                    end

                    def raise_message(message, stack)
                        raise_enriched Errors::RenderingError.new(message), stack
                    end
                end
            end
        end
    end
end
