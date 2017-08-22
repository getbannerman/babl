# frozen_string_literal: true
require 'babl/utils'
require 'set'

module Babl
    module Schema
        class Object < Utils::Value.new(:property_set, :additional)
            def initialize(properties, additional)
                super(properties.to_set.freeze, additional)
            end

            EMPTY = new([], false)
            EMPTY_WITH_ADDITIONAL = new([], true)

            class Property < Utils::Value.new(:name, :value, :required)
                def initialize(name, value, required)
                    super(name, value, required)
                end
            end

            def json
                { type: 'object' }.tap { |out|
                    next if property_set.empty?
                    out[:properties] = property_set.map { |property| [property.name, property.value.json] }.to_h
                    out[:additionalProperties] = additional
                    required_properties = property_set.select(&:required)
                    next if required_properties.empty?
                    out[:required] = property_set.select(&:required).map(&:name).map(&:to_s)
                }
            end
        end
    end
end
