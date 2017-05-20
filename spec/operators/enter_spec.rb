require 'spec_helper'

describe ::Babl::Operators::Enter do
    include SpecHelper::Operators

    describe '#enter' do
        context 'invalid usage' do
            let(:template) { dsl.source { enter } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'valid usage' do
            let(:template) { dsl.source { object(a: enter) } }
            let(:object) { { a: 42 } }

            it { expect(documentation).to eq(a: :__value__) }
            it { expect(dependencies).to eq(a: {}) }
            it { expect(json).to eq('a' => 42) }

            context 'using alias' do
                let(:template) { dsl.source { object(a: _) } }
                it { expect(json).to eq('a' => 42) }
            end
        end
    end
end
