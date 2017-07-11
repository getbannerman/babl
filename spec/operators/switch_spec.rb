require 'spec_helper'

describe Babl::Operators::Switch do
    extend SpecHelper::OperatorTesting

    describe '#switch' do
        context 'realistic use case' do
            template {
                even = nullable.nav(:even?)
                odd = nullable.nav(:odd?)

                each.switch(
                    even => nav { |x| "#{x} is even" },
                    odd => nav { |x| "#{x} is odd" },
                    default => continue
                ).static('WTF')
            }

            let(:object) { [1, 2, nil, 5] }

            it { expect(json).to eq ['1 is odd', '2 is even', 'WTF', '5 is odd'] }
            it { expect(dependencies).to eq(__each__: { even?: {}, odd?: {} }) }
            it { expect(schema).to eq s_dyn_array(s_any_of(s_static('WTF'), s_anything)) }
        end

        context 'static condition' do
            template { switch(true => 42) }

            let(:object) { {} }

            it { expect(json).to eq 42 }
        end

        context 'only one output possible' do
            template { switch(false => 2, true => 2) }

            it { expect(schema).to eq s_static(2) }
        end

        context 'no branch taken' do
            template { switch(false => 1) }

            let(:object) { { abc: { lol: { ok: 42 } } } }

            it { expect(dependencies).to eq({}) }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end

        context 'non serializable objects are allowed internally' do
            template { switch(test: 42) }

            let(:object) { { test: Object.new } }

            it { expect(json).to eq 42 }
        end

        context 'switch between empty array and a dyn array' do
            template { switch(1 => each.object(a: 1), 2 => []) }

            let(:object) { [nil] }

            it { expect(json).to eq(['a' => 1]) }
            it { expect(schema).to eq s_dyn_array(s_object(s_property(:a, s_static(1)))) }
        end

        context 'switch between fixed array and a dyn array producing different output' do
            template { switch(1 => each.static(1), 2 => [2]) }

            it {
                expect(schema).to eq s_any_of(
                    s_dyn_array(s_static(1)), s_fixed_array(s_static(2))
                )
            }
        end

        context 'switch between fixed array and a dyn array producing identical output' do
            template { switch(1 => nullable.each.static(1), 2 => [1]) }

            it { expect(schema).to eq s_dyn_array(s_static(1), nullable: true) }
        end

        context 'switch between similar objects having only one different property' do
            template { switch(1 => { a: 34, b: 3 }, 2 => { a: 34, b: 1 }, 3 => { b: 2, a: 34 }) }

            it {
                expect(schema).to eq s_object(
                    s_property(:a, s_static(34)),
                    s_property(:b, s_any_of(s_static(1), s_static(2), s_static(3)))
                )
            }
        end

        context 'switch between similar objects having more than one different property' do
            template { switch(1 => { a: 35, b: 1 }, 2 => { a: 34, b: 2 }) }

            it {
                expect(schema).to eq s_any_of(
                    s_object(
                        s_property(:a, s_static(35)),
                        s_property(:b, s_static(1))
                    ),
                    s_object(
                        s_property(:a, s_static(34)),
                        s_property(:b, s_static(2))
                    )
                )
            }
        end

        context 'switch between two possible dyn arrays' do
            template { switch(1 => each.static('a'), 2 => each.static('b')) }

            it { expect(schema).to eq s_dyn_array(s_any_of(s_static('a'), s_static('b'))) }
        end

        context 'with dependencies' do
            template { nav(:test).switch(nav(:keke) => parent.nav(:lol)) }

            it { expect(dependencies).to eq(test: { keke: {} }, lol: {}) }
        end
    end
end
