require 'spec_helper'

describe ::Babl::Operators::Array do
    include SpecHelper::Operators

    describe '#array' do
        let(:template) { dsl.source { array('coucou', 45, a: 1, b: [_]) } }
        let(:object) { { b: 12 } }
        it { expect(json).to eq ['coucou', 45, { 'a' => 1, 'b' => [12] }] }
        it { expect(dependencies).to eq(b: {}) }
        it { expect(documentation).to eq ['coucou', 45, a: 1, b: [:__value__]] }
    end
end
