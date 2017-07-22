require 'oj'
require 'babl/rendering'
require 'babl/utils'

module Babl
    module Rendering
        class CompiledTemplate < Utils::Value.new(:node, :dependencies, :preloader, :pretty, :json_schema)
            def json(root)
                data = render(root)
                ::Oj.dump(data, indent: pretty ? 4 : 0, mode: :strict)
            end

            def render(root)
                preloaded_data = preloader.preload([root], dependencies).first
                ctx = Context.new(preloaded_data)
                node.render(ctx)
            end
        end
    end
end
