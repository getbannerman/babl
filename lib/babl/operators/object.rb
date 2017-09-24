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

                    templates = args
                        .map { |name| [name.to_sym, unscoped.nav(name)] }.to_h
                        .merge(kwargs)
                        .map { |k, v| [k, unscoped.call(v)] }

                    construct_terminal { |ctx|
                        Nodes::Object.new(templates.map { |key, template|
                            [
                                key.to_sym,
                                template.builder.precompile(
                                    Nodes::TerminalValue.instance,
                                    ctx.merge(key: key, continue: nil)
                                )
                            ]
                        }.to_h)
                    }
                end
            end
        end
    end
end
