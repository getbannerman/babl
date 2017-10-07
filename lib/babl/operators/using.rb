# frozen_string_literal: true
module Babl
    module Operators
        module Using
            module DSL
                def using(*mods, &block)
                    extended_self =
                        if mods.empty?
                            self
                        else
                            ::Class.new(self.class) { mods.each { |mod| include mod } }.new(builder)
                        end

                    extended_self.source(&(block || -> { self }))
                end
            end
        end
    end
end
