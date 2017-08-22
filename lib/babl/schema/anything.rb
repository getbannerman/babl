# frozen_string_literal: true
require 'babl/utils'
require 'singleton'

module Babl
    module Schema
        class Anything
            include Singleton

            def json
                Utils::Hash::EMPTY
            end
        end
    end
end
