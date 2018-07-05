# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Nav do
    extend SpecHelper::OperatorTesting

    describe '#nav' do
        template { nav(:a) }

        context 'hash navigation' do
            let(:object) { { a: '42' } }

            it { expect(json).to eq('42') }
            it { expect(dependencies).to eq(a: {}) }

            context 'method navigation propagate dependency chain' do
                template { nav(:a).nav(:to_i) }

                it { expect(json).to eq(42) }
                it { expect(dependencies).to eq(a: { to_i: {} }) }
            end
        end

        context 'navigate to BigDecimal' do
            template { nav(:a) }

            let(:object) { { a: BigDecimal('1.3') } }

            it { expect(json).to eq 1.3 }
            it { expect(schema).to eq s_anything }
        end

        context 'navigate to symbol' do
            template { nav(:a) }

            let(:object) { { a: :test } }
            it { expect(json).to eq 'test' }
        end

        context 'navigate to non serializable in nested object' do
            template { nav(:a) }

            let(:object) { { a: { b: [1, 2, { c: 1, d: Object.new }] } } }
            it { expect { json }.to raise_error Babl::Errors::RenderingError, /\__root__\.a\.b\.2\.d/ }
        end

        context 'navigate to string' do
            template { nav('prop') }
            let(:object) { { 'prop' => 1 } }
            it { expect(json).to eq 1 }
        end

        context 'muted method name' do
            let(:method_name) { +'test' }
            template { nav(method_name) }

            before { template }
            before { method_name << '2' }

            let(:object) { { 'test' => 1, 'test2' => 2 } }
            it { expect(json).to eq 1 }
        end

        context 'navigate to serialize object having boolean, numeric & string keys' do
            template { nav(:exotic) }

            let(:object) {
                {
                    exotic: {
                        'str' => 1,
                        12.4 => 2,
                        true => 3,
                        false => 4,
                        :sym => 5
                    }
                }
            }

            it {
                expect(json).to eq(
                    'str' => 1, '12.4' => 2, 'true' => 3, 'false' => 4, 'sym' => 5
                )
            }
        end

        context 'multiple navigation followed by a constant' do
            template { nav(:a).nav(&:itself).nav(:b).static(1) }

            it { expect(json).to eq 1 }
            it { expect(dependencies).to eq({}) }
            it { expect(schema).to eq s_primitive(1) }
        end

        context 'navigate to non serializable in nested object with invalid key' do
            template { nav(:a) }

            let(:object) { { a: { b: [1, 2, { c: 1, Object.new => 1 }] } } }
            it { expect { json }.to raise_error Babl::Errors::RenderingError, /\__root__\.a\.b\.2/ }
        end

        context 'object navigation' do
            let(:object) { Struct.new(:a).new(42) }

            it { expect(json).to eq(42) }
            it { expect(dependencies).to eq(a: {}) }
        end

        context 'block navigation' do
            template { nav { |x| x * 2 } }

            let(:object) { 42 }

            it { expect(json).to eq(84) }
            it { expect(dependencies).to eq({}) }

            context 'block navigation breaks dependency chain' do
                template { nav { |x| x * 2 }.nav(:to_i) }

                it { expect(dependencies).to eq({}) }
            end
        end

        context '#nav should stop key propagation for #enter' do
            template { object(a: nav._) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'nav to array of complex objects' do
            template { nav(:arr) }

            let(:object) { { arr: [nil, 1, 'lol', { a: [1] }, [], {}, true, false] } }

            it { expect(json).to eq([nil, 1, 'lol', { 'a' => [1] }, [], {}, true, false]) }
            it { expect(schema).to eq s_anything }
        end
    end
end
