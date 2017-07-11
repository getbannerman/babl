require 'spec_helper'

describe Babl::Operators::Call do
    extend SpecHelper::OperatorTesting

    describe '#call' do
        context 'primitive' do
            template { call(false) }

            it { expect(json).to eq false }
            it { expect(dependencies).to eq({}) }
            it { expect(schema).to eq s_static(false) }

            context 'call primitive after a conditional' do
                template { nullable.call(34) }

                it { expect(json).to eq nil }
            end
        end

        context 'block' do
            template { call { self * 2 } }

            let(:object) { 2 }

            it { expect(json).to eq 4 }
        end

        context 'hash' do
            template { call('a' => 1, b: 2) }

            it { expect(json).to eq('a' => 1, 'b' => 2) }
            it { expect(dependencies).to eq({}) }
        end

        context 'array' do
            template { call(['a', 2, :b]) }

            let(:object) { { b: 42 } }

            it { expect(json).to eq(['a', 2, 42]) }
            it { expect(dependencies).to eq(b: {}) }
        end

        context 'block' do
            template { call(:lol) }

            let(:object) { OpenStruct.new(lol: 'tam') }

            it { expect(json).to eq 'tam' }
            it { expect(dependencies).to eq(lol: {}) }
        end

        context 'template' do
            template { object(coucou: nav(:a).call(nav(:b))) }

            let(:object) { OpenStruct.new(a: OpenStruct.new(b: 1)) }

            it { expect(dependencies).to eq(a: { b: {} }) }
            it { expect(json).to eq('coucou' => 1) }
            it { expect(schema).to eq(s_object(s_property(:coucou, s_anything))) }
        end
    end
end
