# frozen_string_literal: true
require 'set'

module Babl
    module Utils
        # The idea is to make it possible to call method defined in block's context in addition to DSL methods.
        # Inspired from https://github.com/ms-ati/docile/blob/master/lib/docile/fallback_context_proxy.rb, but
        # here we do not try to handle instance variables, because as far as I know there is no way to do it
        # correctly.
        class DslProxy
            NON_PROXIED_METHODS = Set[
                :__send__, :send, :object_id, :__id__, :equal?, :instance_eval, :instance_exec,
                :respond_to?, :method
            ]

            instance_methods.each do |method|
                undef_method(method) unless NON_PROXIED_METHODS.include?(method)
            end

            # rubocop:disable Style/MethodMissing
            def method_missing(method, *args, &block)
                if @__receiver__.respond_to?(method)
                    @__receiver__.__send__(method, *args, &block)
                else
                    @__fallback__.__send__(method, *args, &block)
                end
            end
            # rubocop:enable Style/MethodMissing

            def respond_to_missing?(method, include_private = false)
                @__receiver__.respond_to?(method, include_private) ||
                    @__fallback__.respond_to?(method, include_private)
            end

            def self.eval(dsl, &block)
                new(dsl, block.binding.receiver).instance_eval(&block)
            end

            def initialize(receiver, fallback)
                @__receiver__ = receiver
                @__fallback__ = fallback
            end
        end
    end
end
