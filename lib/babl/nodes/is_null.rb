# frozen_string_literal: true
require 'babl/utils'
require 'babl/schema'
require 'singleton'

module Babl
    module Nodes
        class IsNull
            include Singleton

            def schema
                Schema::Typed::BOOLEAN
            end

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def renderer(ctx)
                Codegen::Expression.new { |resolver| '::NilClass === ' + resolver.resolve(ctx.object) }
            end

            def optimize
                self
            end
        end
    end
end
