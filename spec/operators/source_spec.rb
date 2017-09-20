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
            template { source('object(a: static(true))', 'file.rb', 3) }

            it { expect(json).to eq('a' => true) }
        end

        context "access to block's context" do
            let(:value) { 42 }
            template { source { object(value: value) } }

            it { expect(json).to eq('value' => 42) }
        end

        context 'dsl proxy as template' do
            template { source { self } }

            it { expect(json).to eq('abc' => { 'def' => 12 }) }
        end
    end
end
