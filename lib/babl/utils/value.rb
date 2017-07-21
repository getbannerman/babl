module Babl
    module Utils
        # Construct deeply immutable value objects
        # Similar to Struct, but:
        # - Properties are assumed deeply immutable (#hash is assumed constant)
        # - Constructor requires all arguments
        # - #== has the same meaning as #eql?
        class Value
            def self.new(*fields)
                ::Class.new(::Struct.new(:_cached_hash, *fields)) do
                    field_aliases = ::Array.new(fields.size) { |i| "v#{i}" }
                    const_set(:FIELDS, fields.map(&:to_sym))
                    class_eval <<-RUBY
                        def initialize(#{field_aliases.join(',')})
                            super(#{['nil', field_aliases].join(',')})
                            hash
                            freeze
                        end

                        def hash
                            self._cached_hash ||= super
                        end

                        def ==(other)
                            eql?(other)
                        end

                        def self.with(hash = {})
                            raise ::ArgumentError unless ::Hash === hash && (hash.keys - FIELDS).empty?
                            new(*FIELDS.map { |f| hash.fetch(f) })
                        end
                    RUBY
                end
            end
        end
    end
end
