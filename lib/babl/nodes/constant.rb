# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'

module Babl
    module Nodes
        class Constant < Utils::Value.new(:value, :schema)
            def render(_ctx)
                value
            end

            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def simplify
                self
            end
        end
    end
end