# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Call do
    extend SpecHelper::OperatorTesting

    describe '#call' do
        context 'primitive' do
            template { call(false) }

            it { expect(json).to eq false }
            it { expect(dependencies).to eq({}) }
            it { expect(schema).to eq s_primitive(false) }

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

        context 'proc' do
            template { call -> { self * 2 } }

            let(:object) { 2 }

            it { expect(json).to eq 4 }
        end

        context 'not interpretable as a template' do
            template { call Object.new }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'hash' do
            template { call('a' => 1, b: 2) }

            it { expect(json).to eq('a' => 1, 'b' => 2) }
            it { expect(dependencies).to eq({}) }
        end

        context 'array' do
            template { call(['a', 2, nav(:b)]) }

            let(:object) { { b: 42 } }

            it { expect(json).to eq(['a', 2, 42]) }
            it { expect(dependencies).to eq(b: {}) }
        end

        context 'symbol' do
            template { call(:lol) }

            it { expect(json).to eq 'lol' }
            it { expect(dependencies).to eq({}) }
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
