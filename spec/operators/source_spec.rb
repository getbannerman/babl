# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Source do
    extend SpecHelper::OperatorTesting

    describe '#source' do
        let(:object) { { abc: { def: 12 } } }

        context 'block returning primitive' do
            template { source { true } }

            it { expect(json).to eq(true) }
        end

        context 'block using operators' do
            template { source { static(3) } }

            it { expect(json).to eq(3) }
        end

        context 'two level sourcing' do
            template { source { nav(:abc).source { nav(:def) } } }

            it { expect(json).to eq(12) }
        end

        context 'string template' do
            template { source('object(a: static(true))') }

            it { expect(json).to eq('a' => true) }
        end
    end
end
