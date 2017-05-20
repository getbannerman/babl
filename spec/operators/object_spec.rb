require 'spec_helper'

describe ::Babl::Operators::Object do
    include SpecHelper::Operators

    describe '#object' do
        let(:template) { dsl.source { object(:a, :b, c: _, d: nav(:d)) } }
        let(:object) { { a: 1, b: 2, c: 3, d: 4 } }

        it { expect(json).to eq('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4) }
        it { expect(documentation).to eq(a: :__value__, b: :__value__, c: :__value__, d: :__value__) }
        it { expect(dependencies).to eq(a: {}, b: {}, c: {}, d: {}) }

        context 'misused (chaining after object)' do
            let(:template) { dsl.source { object(:a).object(:b) } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end
    end
end
