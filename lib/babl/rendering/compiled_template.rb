# frozen_string_literal: true
require 'multi_json'
require 'babl/rendering'
require 'babl/utils'
require 'babl/codegen'
require 'benchmark'

module Babl
    module Rendering
        class CompiledTemplate < Utils::Value.new(:renderer, :dependencies, :preloader, :pretty, :json_schema)
            def json(root)
                data = render(root)
                ::MultiJson.dump(data, pretty: pretty)
            end

            def render(root)
                preloaded_data = preloader.preload([root], dependencies).first
                renderer.evaluate(preloaded_data)
            end
        end
    end
end
