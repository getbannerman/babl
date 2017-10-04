# frozen_string_literal: true
require 'babl/railtie' if defined?(Rails)
require 'babl/template'
require 'babl/version'
require 'babl/rendering'
require 'babl/operators'

module Babl
    class Config
        attr_accessor :preloader, :pretty, :cache_templates, :lookup_context

        def initialize
            @preloader = Rendering::NoopPreloader
            @pretty = true
            @cache_templates = false
            @lookup_context = nil
        end
    end

    class AbsoluteLookupContext
        attr_reader :search_path

        def initialize(search_path)
            @search_path = search_path
            raise Errors::InvalidTemplate, 'Missing search path' unless search_path
        end

        def find(partial_name)
            query = File.join(search_path, "{#{partial_name}}{.babl,}")
            path = Dir[query].first
            return unless path
            source = File.read(path)
            [Babl.source(source, path, 0), self]
        end
    end

    class << self
        def compile(*args, &block)
            raise ArgumentError, 'Wrong number of arguments' if args.size > 1
            raise ArgumentError, 'Template or block expected' unless args.empty? ^ block.nil?

            (args.empty? ? source(&block) : template.call(args.first)).compile(
                pretty: config.pretty,
                preloader: config.preloader,
                lookup_context: config.lookup_context
            )
        end

        def template
            Template.new
        end

        def source(*args, &block)
            template.source(*args, &block)
        end

        def configure
            yield(config)
        end

        def config
            @config ||= Config.new
        end
    end
end
