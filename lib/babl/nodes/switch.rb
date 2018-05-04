# frozen_string_literal: true
require 'babl/schema'
require 'babl/errors'
require 'babl/utils'
require 'babl/nodes/constant'
require 'set'

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

            def render(frame)
                nodes.each { |cond, value| return value.render(frame) if cond.render(frame) }
                raise Errors::RenderingError, 'A least one switch() condition must be taken'
            end

            def optimize
                optimize_condition_and_values ||
                    optimize_falsy_conditions ||
                    optimize_truthy_conditions ||
                    optimize_always_same_outputs ||
                    optimize_same_conditions ||
                    optimize_continue_to_switch ||
                    self
            end

            private

            def optimize_continue_to_switch
                cond, val = nodes.last
                return unless Switch === val && Constant === cond && cond.value
                Switch.new(nodes[0...-1] + val.nodes).optimize
            end

            def optimize_same_conditions
                conds = Set.new
                new_nodes = nodes.map { |cond, val|
                    next if conds.include?(cond)
                    conds << cond
                    [cond, val]
                }.compact
                new_nodes.size == nodes.size ? nil : Switch.new(new_nodes).optimize
            end

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
