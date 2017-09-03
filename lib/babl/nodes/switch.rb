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

            def simplify
                simplify_condition_and_values ||
                    simplify_falsy_conditions ||
                    simplify_truthy_conditions ||
                    simplify_always_same_outputs ||
                    self
            end

            private

            def simplify_always_same_outputs
                return unless nodes.map(&:first).any? { |node| Constant === node && node.value }
                return unless nodes.map(&:last).uniq.size == 1
                nodes.first.last.simplify
            end

            def simplify_truthy_conditions
                nodes[0...-1].each_with_index do |(cond, _value), index|
                    return Switch.new(nodes[0..index]).simplify if Constant === cond && cond.value
                end
                nil
            end

            def simplify_condition_and_values
                simplified = nodes.map { |k, v| [k.simplify, v.simplify] }
                simplified == nodes ? nil : Switch.new(simplified).simplify
            end

            def simplify_falsy_conditions
                simplified = nodes.reject { |(cond, _value)| Constant === cond && !cond.value }
                simplified.size == nodes.size ? nil : Switch.new(simplified).simplify
            end
        end
    end
end
