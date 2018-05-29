# frozen_string_literal: true
module Babl
    module ActionView
        class TemplateHandler
            class_attribute :default_format
            self.default_format = Mime[:json]

            class << self
                def cached_templates
                    @cached_templates ||= {}
                end

                def call(template)
                    Babl.config.cache_templates ? cached_call(template) : uncached_call(template)
                end

                private

                def cached_call(template)
                    cached_templates[template.identifier] ||= Babl.compile {
                        pin { |root|
                            nav(:context).named_pin(:rails_context).call(root.nav(:locals))
                                .source(template.source, template.identifier)
                        }
                    }

                    <<-RUBY
                        compiled = ::Babl::ActionView::TemplateHandler.cached_templates[#{template.identifier.inspect}]
                        compiled.json(locals: local_assigns, context: self)
                    RUBY
                end

                def uncached_call(template)
                    <<-RUBY
                        Babl.compile {
                            pin do |root|
                                nav(:context).named_pin(:rails_context).call(root.nav(:locals)).source(
                                #{template.source.inspect},
                                #{template.identifier.inspect}
                                )
                            end
                        }.json(locals: local_assigns, context: self)
                    RUBY
                end
            end
        end
    end

    class Railtie < Rails::Railtie
        initializer 'babl.initialize' do
            ActiveSupport.on_load(:action_view) do
                ::ActionView::Template.register_template_handler(:babl, Babl::ActionView::TemplateHandler)
            end
        end
    end
end
