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
                tree = precompile(lookup_context: lookup_context)
                tree = tree.optimize if optimize
                validate(tree)

                Rendering::CompiledTemplate.with(
                    preloader: preloader,
                    pretty: pretty,
                    node: tree,
                    dependencies: tree.dependencies,
                    schema: tree.schema
                )
            end

            def self.unscoped
                @unscoped ||= new
            end

            def unscoped
                self.class.unscoped
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
