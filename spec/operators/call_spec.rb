require 'spec_helper'

describe ::Babl::Operators::Call do
    include SpecHelper::Operators

    describe '#call' do
        let(:object) { nil }

        context 'false' do
            let(:template) { dsl.call(false) }

            it { expect(json).to eq false }
            it { expect(dependencies).to eq({}) }
            it { expect(documentation).to eq false }
        end

        context 'block' do
            let(:object) { 2 }
            let(:template) { dsl.call { self * 2 } }

            it { expect(json).to eq 4 }
        end

        context 'hash' do
            let(:object) { nil }
            let(:template) { dsl.call('a' => 1, b: 2) }

            it { expect(json).to eq('a' => 1, 'b' => 2) }
            it { expect(dependencies).to eq({}) }
        end

        context 'array' do
            let(:object) { { b: 42 } }
            let(:template) { dsl.call(['a', 2, :b]) }

            it { expect(json).to eq(['a', 2, 42]) }
            it { expect(dependencies).to eq(b: {}) }
        end

        context 'block' do
            let(:object) { OpenStruct.new(lol: 'tam') }
            let(:template) { dsl.call(:lol) }

            it { expect(json).to eq 'tam' }
            it { expect(dependencies).to eq(lol: {}) }
        end

        context 'template' do
            let(:object) { OpenStruct.new(a: OpenStruct.new(b: 1)) }
            let(:template) { dsl.source { object(coucou: nav(:a).call(nav(:b))) } }

            it { expect(dependencies).to eq(a: { b: {} }) }
            it { expect(json).to eq('coucou' => 1) }
            it { expect(documentation).to eq(coucou: :__value__) }
        end
    end
end
