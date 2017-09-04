# frozen_string_literal: true
require 'coveralls'
Coveralls.wear! do
    add_filter 'spec'
end

require 'bigdecimal'
require 'spec_helper/operator_testing'
require 'spec_helper/schema_utils'
