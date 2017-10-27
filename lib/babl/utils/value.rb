# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Utils
        # Construct deeply immutable value objects
        # Similar to Struct, but:
        # - Properties are assumed deeply immutable (#hash is assumed constant & store permanently)
        # - Constructor requires all arguments
        # - #== has the same meaning as #eql?
        # - The object is frozen
        #
        # Goals :
        # - Create completely immutable value objects
        # - Fast comparison between instances (using precomputed hash values)
        # - Low overhead (relies on native Ruby Struct)
        class Value < Struct
            def self.new(*fields)
                fields = fields.map(&:to_sym)
                field_aliases = ::Array.new(fields.size) { |i| "v#{i}" }

                clazz = super(:_cached_hash, *fields)
                clazz.const_set(:FIELDS, fields)
                clazz.class_eval <<-RUBY
                    def initialize(#{field_aliases.join(',')})
                        super(#{['nil', field_aliases].join(',')})
                        hash
                        freeze
                    end
                RUBY

                clazz
            end

            def hash
                self._cached_hash ||= super
            end

            def ==(other)
                eql?(other)
            end

            def self.with(hash = Utils::Hash::EMPTY)
                raise ::ArgumentError unless ::Hash === hash && (hash.keys - self::FIELDS).empty?
                new(*self::FIELDS.map { |f| hash.fetch(f) })
            end
        end
    end
end
