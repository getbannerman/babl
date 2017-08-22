# frozen_string_literal: true
module Babl
    module ActionView
        module Template
            class Handler
                class_attribute :default_format
                self.default_format = Mime[:json]

                def self.call(template)
                    # This implementation is not efficient: it will recompile the BABL template
                    # for each request. I still don't get why Rails template handlers MUST
                    # return Ruby code ?! Sucks too much. Ideally, we would like to keep the compiled
                    # template somewhere. However, I've not yet measured how much like is wasted.
                    # Maybe it is negligible ?
                    <<~RUBY
                        Babl.compile { #{template.source} }.json(local_assigns)
                    RUBY
                end
            end
        end
    end

    class Railtie < Rails::Railtie
        initializer "babl.initialize" do
            ActiveSupport.on_load(:action_view) do
                ::ActionView::Template.register_template_handler(:babl, Babl::ActionView::Template::Handler)
            end
        end
    end
end
