require 'values'
require 'set'

module Babl
    module Schema
        class Object < Value.new(:property_set, :additional, :nullable)
            attr_reader :properties

            def initialize(properties, additional, nullable)
                @properties = properties
                super(properties.to_set, additional, nullable)
            end

            class Property < Value.new(:name, :value, :required)
                def initialize(name, value, required)
                    super(name, value, required)
                end
            end

            EMPTY = new([], false, false)
            EMPTY_WITH_ADDITIONAL = new([], true, false)

            def json
                { type: nullable ? %w[object null] : 'object' }.tap { |out|
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
