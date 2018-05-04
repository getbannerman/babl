# frozen_string_literal: true
require 'spec_helper'
require 'benchmark'

describe 'Reference benchmark' do
    extend SpecHelper::OperatorTesting

    context 'perf test' do
        template {
            {
                list: pin(:size) { |size|
                    each.object(
                        id: _.integer,
                        static_val: { a: 1 },
                        blabla: _.nullable.object(:status),
                        outer_list_size: size,
                        prop4: _,
                        nested: _.each.nav(:sub).object(
                            prop1: _.string,
                            prop2: _.nullable.number,
                            prop3: _.boolean,
                            prop4: _,
                            prop5: _,
                            prop6: _,
                            parent_id: [parent.parent.parent.nav(:id)]
                        )
                    )
                }
            }
        }

        let(:object) {
            nested_struct = Struct.new(:prop1, :prop2, :prop3, :prop4, :prop5, :prop6)

            Array.new(200) { |i|
                {
                    id: i,
                    prop4: 1,
                    blabla: i.even? ? nil : { status: { obj: [1, 2], str: 'bla' } },
                    nested: Array.new(100) { |j|
                        {
                            sub: nested_struct.new('str', j * 1.1, true, nil, { a: j }, '')
                        }
                    }
                }
            }
        }

        before { compiled }
        before { object }

        it {
            GC.start
            GC.disable
            nb_before = GC.stat[:total_allocated_objects]
            Benchmark.bm { |x|
                x.report('Reference BABL benchmark') { 10.times { compiled.render(object) } }
            }
            nb_after = GC.stat[:total_allocated_objects]
            GC.enable
            puts "Allocations: #{nb_after - nb_before}"
        }
    end
end
