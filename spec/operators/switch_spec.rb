require 'spec_helper'

describe ::Babl::Operators::Switch do
    include SpecHelper::Operators

    describe '#switch' do
        context do
            let(:template) {
                dsl.source {
                    even = nullable.nav(:even?)
                    odd = nullable.nav(:odd?)

                    each.switch(
                        even => nav { |x| "#{x} is even" },
                        odd => nav { |x| "#{x} is odd" },
                        default => continue
                    ).static('WTF')
                }
            }

            let(:object) { [1, 2, nil, 5] }

            it { expect(json).to eq ['1 is odd', '2 is even', 'WTF', '5 is odd'] }
            it { expect(dependencies).to eq(__each__: { even?: {}, odd?: {} }) }
            it {
                expect(documentation).to eq [
                    'Case 1': :__value__,
                    'Case 2': :__value__,
                    'Case 3': 'WTF'
                ]
            }
        end

        context 'static condition' do
            let(:template) { dsl.source { switch(true => 42) } }
            let(:object) { {} }
            it { expect(json).to eq 42 }
        end

        context 'navigation before continue' do
            let(:template) { dsl.source { nav(:abc).switch(false => 1, default => nav(:lol).continue).object(val: nav(:ok)) } }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'continue in sub-object' do
            let(:template) { dsl.source { object(a: switch(default => object(x: continue))) } }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'unhandled default' do
            let(:object) { { abc: { lol: { ok: 42 } } } }
            let(:template) { dsl.source { switch(false => 1) } }

            it { expect(dependencies).to eq({}) }
            it { expect { json }.to raise_error Babl::RenderingError }
        end

        context 'continue without switch' do
            let(:template) { dsl.source { continue } }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'non serializable objects are allowed internally' do
            let(:template) { dsl.source { switch(test: 42) } }
            let(:object) { { test: Object.new } }

            it { expect(json).to eq 42 }
        end

        context do
            let(:template) {
                dsl.source {
                    nav(:test).switch(nav(:keke) => parent.nav(:lol))
                }
            }
            it { expect(dependencies).to eq(test: { keke: {} }, lol: {}) }
        end
    end
end
