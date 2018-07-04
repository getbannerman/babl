# frozen_string_literal: true
require 'babl/utils'

module Babl
    module Utils
        # Construct deeply immutable value objects
        # Similar to Struct, but:
        # - Properties are assumed deeply immutable (#hash is assumed constant & store permanently)
        # - Constructor requires all arguments
        # - #== has the same meaning as #eql?
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
                    end
                RUBY

                fields.each { |field|
                    clazz.send(:define_method, :"#{field}=") { |*| raise ::RuntimeError, 'Object is immutable' }
                }

                clazz
            end

            def hash
                self._cached_hash ||= super
            end

            def ==(other)
                eql?(other)
            end

            class << self
                def with(hash = Utils::Hash::EMPTY)
                    raise ::ArgumentError unless ::Hash === hash && (hash.keys - self::FIELDS).empty?
                    new(*self::FIELDS.map { |f| hash.fetch(f) })
                end

                private

                def memoize(method_name)
                    old_name = :"_unmemoized_#{method_name}"
                    alias_method old_name, method_name

                    class_eval <<-SQL
                        def #{method_name}
                            return @#{old_name} if defined? @#{old_name}
                            @#{old_name} = #{old_name}
                        end
                    SQL
                end
            end
        end
    end
end
