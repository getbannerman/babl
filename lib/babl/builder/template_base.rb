module Babl
    module Builder
        # TemplateBase is a thin wrapper around Builder.
        #
        # Since the BABL code is run via #instance_eval within an instance of this class, we want to
        # define as few methods as possible here.
        class TemplateBase
            def initialize(builder = ChainBuilder.new(&:itself))
                @builder = builder
            end

            def compile(**options)
                Rendering::CompiledTemplate.new(precompile, **options)
            end

            protected

            def unscoped
                self.class.new builder.rescope(&:itself)
            end

            def precompile
                builder.precompile(Babl::Rendering::TerminalValueNode.instance)
            end

            def construct_node(**new_context, &block)
                self.class.new builder.construct_node(**new_context, &block)
            end

            def construct_terminal(&block)
                self.class.new builder.construct_terminal(&block)
            end

            attr_reader :builder
        end
    end
end
