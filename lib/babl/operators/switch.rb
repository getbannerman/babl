module Babl
    module Operators
        module Switch
            module DSL
                # To be used as a switch(...) condition. It is strictly equivalent to write 'true' instead,
                # but convey more meaning.
                def default
                    unscoped.static(true)
                end

                # Return a special placeholder that can be used as a switch(...) value. It tells BABL to continue
                # the evaluation of the original chain after switch().
                def continue
                    construct_terminal { |context|
                        node = context[:continue]
                        raise Babl::InvalidTemplateError, 'continue() cannot be used outside switch()' unless node
                        node
                    }
                end

                # Conditional switching
                def switch(conds = {})
                    construct_node(continue: nil) { |node, context|
                        nodes = conds.map { |cond, value|
                            cond_node = unscoped.call(cond).builder
                                .precompile(Rendering::InternalValueNode.instance, context.merge(continue: nil))

                            value_node = unscoped.call(value).builder
                                .precompile(Rendering::TerminalValueNode.instance, context.merge(continue: node))

                            [cond_node, value_node]
                        }.to_h

                        SwitchNode.new(nodes)
                    }
                end
            end

            class SwitchNode
                def initialize(nodes)
                    @nodes = nodes
                end

                def dependencies
                    (nodes.values + nodes.keys).map(&:dependencies)
                        .reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def pinned_dependencies
                    (nodes.values + nodes.keys).map(&:pinned_dependencies)
                        .reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def documentation
                    (nodes.values).map(&:documentation).each_with_index.map { |doc, idx|
                        [:"Case #{idx + 1}", doc]
                    }.to_h
                end

                def render(ctx)
                    nodes.each { |cond, value| return value.render(ctx) if cond.render(ctx) }
                    raise Babl::RenderingError, 'A least one switch() condition must be taken'
                end

                private

                attr_reader :nodes, :default_node
            end
        end
    end
end
