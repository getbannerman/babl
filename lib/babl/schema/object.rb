require 'babl/utils/value'
require 'set'

module Babl
    module Schema
        class Object < Utils::Value.new(:property_set, :additional)
            attr_reader :properties

            def initialize(properties, additional)
                @properties = properties
                super(properties.to_set, additional)
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
                    next if properties.empty?
                    out[:properties] = properties.map { |property| [property.name, property.value.json] }.to_h
                    out[:additionalProperties] = additional
                    required_properties = properties.select(&:required)
                    next if required_properties.empty?
                    out[:required] = properties.select(&:required).map(&:name).map(&:to_s)
                }
            end
        end
    end
end
