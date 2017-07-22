# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'

module Babl
    module Nodes
        class Constant < Utils::Value.new(:value, :schema)
            def dependencies
                Utils::Hash::EMPTY
            end

            def pinned_dependencies
                Utils::Hash::EMPTY
            end

            def renderer(_ctx)
                res = Codegen::Resource.new(value)
                Codegen::Expression.new { |resolver| resolver.resolve(res) }
            end

            def optimize
                self
            end
        end
    end
end
