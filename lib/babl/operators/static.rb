module Babl
    module Operators
        module Static
            module DSL
                # Create a static JSON value
                def static(value)
                    construct_terminal { StaticNode.new(value) }
                end
            end

            class StaticNode
                def initialize(value)
                    @serialized_value = Rendering::TerminalValueNode.instance.render_object(value)
                rescue Babl::RenderingError => exception
                    raise Babl::InvalidTemplateError, exception.message
                end

                def documentation
                    serialized_value
                end

                def render(_ctx)
                    serialized_value
                end

                def dependencies
                    {}
                end

                def pinned_dependencies
                    {}
                end

                private

                attr_reader :serialized_value
            end
        end
    end
end
