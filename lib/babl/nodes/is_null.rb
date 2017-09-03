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

            def render(ctx)
                ::NilClass === ctx.object
            end
        end
    end
end
