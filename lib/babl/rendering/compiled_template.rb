# frozen_string_literal: true
require 'multi_json'
require 'babl/rendering'
require 'babl/utils'

module Babl
    module Rendering
        class CompiledTemplate < Utils::Value.new(:node, :dependencies, :preloader, :pretty, :json_schema)
            def json(root)
                data = render(root)
                ::MultiJson.dump(data, pretty: pretty)
            end

            def render(root)
                preloaded_data = preloader.preload([root], dependencies).first
                context = Context.new
                frame = Context::Frame.new(preloaded_data)
                node.render(context, frame)
            end
        end
    end
end
