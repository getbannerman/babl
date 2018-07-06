# frozen_string_literal: true
require 'babl/railtie' if defined?(Rails)
require 'babl/template'
require 'babl/version'
require 'babl/rendering'
require 'babl/operators'

module Babl
    # There is basically two ways to use BABL: the Rails way, and the clean way.
    #
    # Rails way
    # - BABL detects Rails and integrates with it automatically (only if BABL is required AFTER Rails).
    # - BABL configuration is global (defined via Babl.configure).
    # - Global configuration is also used by:
    #      Babl.template
    #      Babl.compile
    #      Babl.source
    #
    # Clean way
    # - You can decide not to use global configuration. It will result in more verbosity
    #   but it protects you from global settings.
    # - Equivalences:
    #       Babl.template  ==> Babl::Template.new
    #       Babl.compile   ==> Babl::Template#compile
    #       Babl.source    ==> Babl::Template#source
    #
    class Config
        attr_accessor :preloader, # No practical use outside Bannerman today.
            :pretty,              # Pretty format JSON output (boolean).
            :cache_templates,     # Enable or disable caching of compiled templates (Rails only, boolean).
            :lookup_context,      # Specify how to find templates.
            :using                # List of user-defined modules containing custom operators.

        def initialize
            @preloader = Rendering::NoopPreloader
            @pretty = true
            @cache_templates = false
            @lookup_context = nil
            @using = []
        end
    end

    class AbsoluteLookupContext
        attr_reader :search_path

        def initialize(search_path)
            @search_path = search_path
            raise Errors::InvalidTemplate, 'Missing search path' unless search_path
        end

        def find(current_template, partial_name)
            query = File.join(search_path, "{#{partial_name}}{.babl,}")
            path = Dir[query].first
            return unless path
            source = File.read(path)
            [current_template.source(source, path, 0), self]
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

        def source(*args, &block)
            template.source(*args, &block)
        end

        def template
            cached = @cached_template
            return cached.last if cached && [config.using].flatten == cached.first
            # Calling 'using' is a very inefficient operation, because
            # it creates a new class. We can avoid that cost most of the
            # time, assuming 'config.using' does not change often (typically
            # it should only change once at startup)
            modules = [config.using].flatten.dup
            template = Template.new.using(*modules)
            @cached_template = [modules, template]
            template
        end

        def configure
            yield(config)
        end

        def config
            @config ||= Config.new
        end
    end
end
