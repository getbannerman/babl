require 'spec_helper'

describe ::Babl::Operators::Source do
    include SpecHelper::Operators

    describe '#source' do
        let(:object) { { abc: { def: 12 } } }

        context 'block returning primitive' do
            let(:template) { dsl.source { true } }
            it { expect(json).to eq(true) }
        end

        context 'block using operators' do
            let(:template) { dsl.source { static(3) } }
            it { expect(json).to eq(3) }
        end

        context 'two level sourcing' do
            let(:template) { dsl.source { nav(:abc).source { nav(:def) } } }
            it { expect(json).to eq(12) }
        end

        context 'string template' do
            let(:template) { dsl.source('object(a: static(true))') }
            it { expect(json).to eq('a' => true) }
        end
    end
end
