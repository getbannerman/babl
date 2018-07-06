# frozen_string_literal: true
module Babl
    module Utils
        class Proc
            class << self
                # Wrap a proc in a lambda, so that it is executed in the context of its first (and only) argument.
                def selfify(proc)
                    ->(this) { this.instance_exec(&proc) }
                end

                # Create a lambda returning a constant.
                def constant(value)
                    -> { value }
                end
            end
        end
    end
end
