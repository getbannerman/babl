# frozen_string_literal: true
module Babl
    module Utils
        class Hash
            EMPTY = {}.freeze

            def self.deep_merge(*hashes)
                filtered_hashes = hashes.reject(&:empty?)
                return EMPTY if filtered_hashes.empty?
                return filtered_hashes.first if filtered_hashes.size == 1
                filtered_hashes.reduce({}) { |out, hash| deep_merge_inplace(out, hash) }
            end

            def self.deep_merge_inplace(target, source)
                source.each { |k, v| target[k] = deep_merge_inplace(target[k] || {}, v) }
                target
            end
        end
    end
end
