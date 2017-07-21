require 'babl/utils/hash'
require 'babl/utils/value'

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

            private

            def canonicalize(path)
                case path
                when ::Array then path.reduce({}) { |a, p| a.merge(canonicalize(p)) }
                when ::Hash then path.map { |k, v| [k.to_sym, canonicalize(v)] }.to_h
                else { path.to_sym => {} }
                end
            end
        end
    end
end
