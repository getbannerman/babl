module Babl
    module Operators
        module Merge
            module DSL
                # Merge multiple JSON objects (non-deep)
                def merge(*templates)
                    construct_terminal { |context|
                        MergeNode.new(
                            templates.map { |t|
                                unscoped.call(t).builder.precompile(
                                    Rendering::TerminalValueNode.instance,
                                    context.merge(continue: nil)
                                )
                            }
                        )
                    }
                end
            end

            class MergeNode
                def initialize(nodes)
                    @nodes = nodes
                end

                def dependencies
                    nodes.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def pinned_dependencies
                    nodes.map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def documentation
                    nodes.map(&:documentation).each_with_index.map { |doc, idx|
                        [:"Merge #{idx + 1}", doc]
                    }.to_h
                end

                def render(ctx)
                    nodes.map { |node| node.render(ctx) }.compact.reduce({}, :merge)
                end

                private

                attr_reader :nodes
            end
        end
    end
end
