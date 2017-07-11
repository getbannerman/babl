require 'babl/errors'

module Babl
    module Operators
        module Partial
            module DSL
                # Load a partial template given its name
                # A 'lookup_context' must be defined
                def partial(partial_name)
                    raise Errors::InvalidTemplateError, "Cannot use partial without lookup context" unless lookup_context

                    path, source, partial_lookup_context = lookup_context.find(partial_name)
                    raise Errors::InvalidTemplateError, "Cannot find partial '#{partial_name}'" unless path

                    with_lookup_context(partial_lookup_context)
                        .source(source, path, 0)
                        .with_lookup_context(lookup_context)
                end

                def with_lookup_context(lookup_context)
                    self.class.new(builder.dup.tap { |inst| inst.instance_variable_set(:@lookup_context, lookup_context) })
                end

                def lookup_context
                    builder.instance_variable_get(:@lookup_context)
                end
            end

            class AbsoluteLookupContext
                attr_reader :search_path

                def initialize(search_path)
                    @search_path = search_path
                    raise 'Invalid search path' unless search_path
                end

                def find(partial_name)
                    query = File.join(search_path, "{#{partial_name}}{.babl,}")
                    path = Dir[query].first
                    return unless path

                    source = File.read(path)
                    [path, source, self]
                end
            end
        end
    end
end
