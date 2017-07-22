# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Codegen
        LinkedExpression = Utils::Value.new(:name, :inputs, :expression, :called_linked_expressions, :code)
    end
end
