# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Nodes
        class Dep < Utils::Value.new(:node, :path)
            def initialize(node, path)
                super(node, canonicalize(path))
            end

            def render(ctx)
                node.render(ctx)
            end

            def schema
                node.schema
            end

            def pinned_dependencies
                node.pinned_dependencies
            end

            def dependencies
                Babl::Utils::Hash.deep_merge(node.dependencies, path)
            end

            def simplify
                Dep.new(node.simplify, path)
            end

            private

            def canonicalize(path)
                case path
                when ::Array then path.reduce(Utils::Hash::EMPTY) { |a, p| a.merge(canonicalize(p)) }
                when ::Hash then path.map { |k, v| [k.to_sym, canonicalize(v)] }.to_h
                else { path.to_sym => Utils::Hash::EMPTY }
                end
            end
        end
    end
end
