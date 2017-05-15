module Babl
    module Operators
        module Object
            module DSL
                # Create a JSON object node with static structure
                def object(*attrs, **nested)
                    (attrs.map(&:to_sym) + nested.keys).group_by(&:itself).values.each do |keys|
                        raise ::Babl::InvalidTemplateError, "Duplicate key in object(): #{keys.first}" if keys.size > 1
                    end

                    construct_terminal { |ctx|
                        nodes = attrs
                            .map { |name| [name.to_sym, unscoped.enter] }.to_h
                            .merge(nested)
                            .map { |k, v|
                                [k, unscoped.call(v).builder.precompile(
                                    Rendering::TerminalValueNode.instance,
                                    ctx.merge(key: k, continue: nil)
                                )]
                            }
                            .to_h

                        ObjectNode.new(nodes)
                    }
                end
            end

            class ObjectNode
                def initialize(nodes)
                    @nodes = nodes
                end

                def dependencies
                    nodes.values.map(&:dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def pinned_dependencies
                    nodes.values.map(&:pinned_dependencies).reduce({}) { |a, b| Babl::Utils::Hash.deep_merge(a, b) }
                end

                def documentation
                    nodes.map { |k, v| [k, v.documentation] }.to_h
                end

                def render(ctx)
                    nodes.map { |k, v| [k, v.render(ctx)] }.to_h
                end

                private

                attr_reader :nodes
            end
        end
    end
end
