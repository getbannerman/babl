# frozen_string_literal: true
require 'babl/errors'
require 'babl/nodes'

module Babl
    module Operators
        module Enter
            KEY_QUESTIONIFIER = proc { |context|
                key = context[:key]

                new_key =
                    case key
                    when ::String then "#{key}?"
                    when ::Symbol then :"#{key}?"
                    else raise Errors::InvalidTemplate, "Key is expected to key a string or a symbol: #{key}"
                    end

                context.merge(key: new_key)
            }

            module DSL
                # Navigate to a property whose name is inferred based on parent object()'s key
                def enter
                    construct_node { |node, context|
                        raise Errors::InvalidTemplate, 'No key to enter into' unless context.key?(:key)

                        Nodes::Nav.new(context[:key], node)
                    }.reset_key.reset_continue
                end

                # Navigate to a property whose name is inferred based on parent object()'s key + '?'
                def enter?
                    construct_context(&KEY_QUESTIONIFIER).enter
                end

                # Simple convenience alias
                def _
                    enter
                end

                # Simple convenience alias
                def _?
                    enter?
                end

                protected

                # Clear contextual information about current property name for the rest of the chain
                def reset_key
                    construct_context { |context|
                        next context unless context.key?(:key)

                        context.reject { |k, _v| :key == k }
                    }
                end
            end
        end
    end
end
