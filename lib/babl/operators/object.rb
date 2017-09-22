# frozen_string_literal: true
require 'babl/nodes'
require 'babl/errors'

module Babl
    module Operators
        module Object
            module DSL
                # Create a JSON object node with static structure
                def object(*args)
                    kwargs = ::Hash === args.last ? args.pop : {}

                    (args.map(&:to_sym) + kwargs.keys.map(&:to_sym)).group_by(&:itself).each_value do |keys|
                        raise Errors::InvalidTemplate, "Duplicate key in object(): #{keys.first}" if keys.size > 1
                    end

                    construct_terminal { |ctx|
                        nodes = args
                            .map { |name| [name.to_sym, unscoped.nav(name)] }.to_h
                            .merge(kwargs)
                            .map { |k, v|
                                [k.to_sym, unscoped.call(v).builder.precompile(
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
