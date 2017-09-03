# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class Object < Utils::Value.new(:nodes)
            EMPTY = new({})

            def dependencies
                nodes.values.map(&:dependencies).reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.values.map(&:pinned_dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                properties = nodes.map { |k, v| Schema::Object::Property.new(k, v.schema, true) }
                Schema::Object.new(properties, false)
            end

            def render(ctx)
                out = {}
                nodes.each { |k, v| out[k] = v.render(ctx) }
                out
            end

            def simplify
                simplify_values ||
                    simplify_constant ||
                    self
            end

            private

            def simplify_values
                simplified_nodes = nodes.map { |k, v| [k, v.simplify] }.to_h
                simplified_nodes == nodes ? nil : Object.new(simplified_nodes).simplify
            end

            def simplify_constant
                return unless nodes.values.all? { |node| Constant === node }
                Constant.new(render(nil), schema)
            end
        end
    end
end
