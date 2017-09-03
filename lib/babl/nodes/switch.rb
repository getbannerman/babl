# frozen_string_literal: true
require 'babl/schema'
require 'babl/errors'
require 'babl/utils'
require 'babl/nodes/constant'

module Babl
    module Nodes
        class Switch < Utils::Value.new(:nodes)
            def initialize(nodes)
                raise Errors::InvalidTemplate, 'A least one switch() condition must be taken' if nodes.empty?
                super
            end

            def dependencies
                nodes.flatten(1).map(&:dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def pinned_dependencies
                nodes.flatten(1).map(&:pinned_dependencies)
                    .reduce(Utils::Hash::EMPTY) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
            end

            def schema
                Schema::AnyOf.canonicalized(nodes.map(&:last).map(&:schema))
            end

            def render(ctx)
                nodes.each { |cond, value| return value.render(ctx) if cond.render(ctx) }
                raise Errors::RenderingError, 'A least one switch() condition must be taken'
            end

            def optimize
                optimize_condition_and_values ||
                    optimize_falsy_conditions ||
                    optimize_truthy_conditions ||
                    optimize_always_same_outputs ||
                    self
            end

            private

            def optimize_always_same_outputs
                return unless nodes.map(&:first).any? { |node| Constant === node && node.value }
                return unless nodes.map(&:last).uniq.size == 1
                nodes.first.last.optimize
            end

            def optimize_truthy_conditions
                nodes[0...-1].each_with_index do |(cond, _value), index|
                    return Switch.new(nodes[0..index]).optimize if Constant === cond && cond.value
                end
                nil
            end

            def optimize_condition_and_values
                optimized = nodes.map { |k, v| [k.optimize, v.optimize] }
                optimized == nodes ? nil : Switch.new(optimized).optimize
            end

            def optimize_falsy_conditions
                optimized = nodes.reject { |(cond, _value)| Constant === cond && !cond.value }
                optimized.size == nodes.size ? nil : Switch.new(optimized).optimize
            end
        end
    end
end
