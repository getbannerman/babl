module Babl
    module Utils
        class Hash
            # Source: http://stackoverflow.com/a/9381776/1434017 (Jon M)
            def self.deep_merge(first, second)
                merger = proc { |_key, v1, v2| ::Hash === v1 && ::Hash === v2 ? v1.merge(v2, &merger) : v2 }
                first.merge(second, &merger)
            end
        end
    end
end
