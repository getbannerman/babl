require 'oj'

module Babl
    module Rendering
        class CompiledTemplate
            attr_reader :node, :dependencies, :documentation, :preloader, :pretty

            def initialize(node, preloader: NoopPreloader, pretty: true)
                @node = node
                @dependencies = node.dependencies
                @documentation = node.documentation
                @preloader = preloader
                @pretty = pretty
            end

            def json(root)
                data = render(root)
                Oj.dump(data, indent: pretty ? 4 : 0, mode: :strict)
            end

            def render(root)
                preloaded_data = preloader.preload([root], dependencies).first
                ctx = Babl::Rendering::Context.new(preloaded_data)
                node.render(ctx)
            end
        end
    end
end
