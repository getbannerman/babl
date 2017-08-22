# frozen_string_literal: true
require 'babl/nodes'
require 'babl/builder'
require 'babl/rendering'

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

            def compile(preloader: Rendering::NoopPreloader, pretty: true)
                node = precompile

                Rendering::CompiledTemplate.with(
                    preloader: preloader,
                    pretty: pretty,
                    node: node,
                    dependencies: node.dependencies,
                    json_schema: node.schema.json
                )
            end

            protected

            def unscoped
                self.class.new builder.rescope(&:itself)
            end

            def precompile
                builder.precompile(Nodes::TerminalValue.instance)
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
