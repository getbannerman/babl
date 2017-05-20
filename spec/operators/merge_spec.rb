require 'spec_helper'

describe ::Babl::Operators::Merge do
    include SpecHelper::Operators

    describe '#merge' do
        context do
            let(:template) {
                dsl.source {
                    merge(
                        object(a: static('A')),
                        b: _
                    )
                }
            }

            let(:object) { { b: 42 } }

            it { expect(json).to eq('a' => 'A', 'b' => 42) }
            it { expect(dependencies).to eq(b: {}) }
            it { expect(documentation).to eq('Merge 1': { a: 'A' }, 'Merge 2': { b: :__value__ }) }
        end

        context 'merge inside object' do
            let(:template) { dsl.source { object(toto: merge(_, lol: 42)) } }
            let(:object) { { toto: { cool: 'ouai' } } }

            it { expect(json).to eq('toto' => { 'lol' => 42, 'cool' => 'ouai' }) }
        end
    end
end
