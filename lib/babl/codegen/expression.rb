# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Codegen
        class Expression < Utils::Value.new(:code)
            def initialize(&block)
                super(block)
            end
        end
    end
end
