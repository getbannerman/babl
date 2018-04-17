# frozen_string_literal: true
require 'babl/schema'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class Object < Utils::Value.new(:nodes)
            EMPTY = new(Utils::Hash::EMPTY)

            memoize def dependencies
                Babl::Utils::Hash.deep_merge(nodes.values.map(&:dependencies))
            end

            memoize def pinned_dependencies
                Babl::Utils::Hash.deep_merge(nodes.values.map(&:pinned_dependencies))
            end

            memoize def schema
                properties = nodes.map { |k, v| Schema::Object::Property.new(k, v.schema, true) }
                Schema::Object.new(properties, false)
            end

            memoize def optimize
                optimized_nodes = nodes.map { |k, v| [k, v.optimize] }.to_h
                object = self if optimized_nodes.all? { |k, v| v.equal?(nodes[k]) }
                object ||= Object.new(optimized_nodes)

                return object unless optimized_nodes.values.all? { |node| Constant === node }

                Constant.new(optimized_nodes.map { |k, v| [k, v.value] }.to_h.freeze, object.schema)
            end

            def render(frame)
                generate_render_method
                render_impl(frame)
            end

            def generate_render_method
                return if @generated

                ruby_props = nodes.each_with_index.map do |(key, node), index|
                    varname = "@node_#{index}"
                    instance_variable_set(varname, node)
                    "#{key.inspect} => #{varname}.render(frame)"
                end

                singleton_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def render_impl(frame)
                        {#{ruby_props.join(',')}}
                    end
                RUBY

                @generated = true
            end
        end
    end
end
