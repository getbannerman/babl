# frozen_string_literal: true
require 'babl/nodes'
require 'babl/utils'
require 'babl/builder'
require 'babl/rendering'

module Babl
    module Builder
        # TemplateBase is a thin wrapper around Builder.
        #
        # Since the BABL code is run via #instance_exec within an instance of this class, we want to
        # define as few methods as possible here.
        class TemplateBase
            def initialize(builder = ChainBuilder.new(&:itself))
                @builder = builder
                freeze
            end

            def compile(preloader: Rendering::NoopPreloader, pretty: true, optimize: true, lookup_context: nil)
                # Compute dependencies & schema on the non-simplified node tree in order
                # to catch all errors.
                tree = precompile(lookup_context: lookup_context)
                validate(tree)

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
                    schema: schema
                )
            end

            def unscoped
                self.class.new
            end

            protected

            attr_reader :builder

            def validate(tree)
                # NOOP
            end

            def precompile(node = Nodes::TerminalValue.instance, **context)
                builder.precompile(node, **context)
            end

            def construct_node(**new_context, &block)
                self.class.new builder.construct_node(**new_context, &block)
            end

            def construct_terminal(&block)
                self.class.new builder.construct_terminal(&block)
            end
        end
    end
end
