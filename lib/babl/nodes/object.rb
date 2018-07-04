# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class Object < Utils::Value.new(:nodes)
            EMPTY = new(Utils::Hash::EMPTY)

            def dependencies
                Babl::Utils::Hash.deep_merge(*nodes.values.map(&:dependencies))
            end

            def pinned_dependencies
                Babl::Utils::Hash.deep_merge(*nodes.values.map(&:pinned_dependencies))
            end

            def schema
                properties = nodes.map { |k, v| Schema::Object::Property.new(k, v.schema, true) }
                Schema::Object.new(properties, false)
            end

            def render(frame)
                out = {}
                nodes.each { |k, v| out[k] = v.render(frame) }
                out
            end

            def optimize
                optimized_nodes = nodes.map { |k, v| [k, v.optimize] }.to_h
                optimized_object = Object.new(optimized_nodes)
                return optimized_object unless optimized_nodes.values.all? { |node| Constant === node }
                Constant.new(optimized_object.nodes.map { |k, v| [k, v.value] }.to_h.freeze, optimized_object.schema)
            end
        end
    end
end
