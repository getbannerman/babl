require 'babl/nodes/object'
require 'babl/nodes/terminal_value'
require 'babl/errors'

module Babl
    module Operators
        module Object
            module DSL
                # Create a JSON object node with static structure
                def object(*attrs, **nested)
                    (attrs.map(&:to_sym) + nested.keys).group_by(&:itself).values.each do |keys|
                        raise Errors::InvalidTemplateError, "Duplicate key in object(): #{keys.first}" if keys.size > 1
                    end

                    construct_terminal { |ctx|
                        nodes = attrs
                            .map { |name| [name.to_sym, unscoped.enter] }.to_h
                            .merge(nested)
                            .map { |k, v|
                                [k, unscoped.call(v).builder.precompile(
                                    Nodes::TerminalValue.instance,
                                    ctx.merge(key: k, continue: nil)
                                )]
                            }
                            .to_h

                        Nodes::Object.new(nodes)
                    }
                end
            end
        end
    end
end
