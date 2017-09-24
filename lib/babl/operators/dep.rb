# frozen_string_literal: true
require 'babl/nodes'

module Babl
    module Operators
        module Dep
            def self.canonicalize(path)
                case path
                when ::Array then path.reduce(Utils::Hash::EMPTY) { |a, p| a.merge(canonicalize(p)) }
                when ::Hash then path.map { |k, v| [k.dup.freeze, canonicalize(v)] }.to_h
                else { path.dup.freeze => Utils::Hash::EMPTY }
                end
            end

            module DSL
                # Declare dependencies as if they were generated by nav()
                # but without navigating.
                def dep(*path)
                    path = Dep.canonicalize(path)
                    construct_node(continue: nil) { |node| Nodes::Dep.new(node, path) }
                end
            end
        end
    end
end
