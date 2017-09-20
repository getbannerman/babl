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

            def compile(preloader: Rendering::NoopPreloader, pretty: true, optimize: true)
                # Compute dependencies & schema on the non-simplified node tree in order
                # to catch all errors.
                tree = precompile
                dependencies = tree.dependencies
                schema = tree.schema

                # Recompute dependencies & schema on the simplified tree before
                # exposing them to the user.
                if optimize
                    tree = tree.optimize
                    dependencies = tree.dependencies
                    schema = tree.schema
                end

                Rendering::CompiledTemplate.with(
                    preloader: preloader,
                    pretty: pretty,
                    node: tree,
                    dependencies: dependencies,
                    json_schema: schema.json
                )
            end

            def unscoped
                self.class.new builder.rescope(&:itself)
            end

            protected

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
