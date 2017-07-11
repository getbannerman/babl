require 'spec_helper'

describe Babl::Operators::Nav do
    extend SpecHelper::OperatorTesting

    describe '#nav' do
        template { nav(:a) }

        context 'hash navigation' do
            let(:object) { { a: 42 } }
            it { expect(json).to eq(42) }
            it { expect(dependencies).to eq(a: {}) }

            context 'block navigation propagate dependency chain' do
                template { nav(:a).nav(:to_i) }
                it { expect(dependencies).to eq(a: { to_i: {} }) }
            end
        end

        context 'navigate to non serializable' do
            template { nav(:a) }
            let(:object) { { a: :test } }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end

        context 'navigate to non serializable in nested object' do
            template { nav(:a) }
            let(:object) { { a: { b: [1, 2, { c: 1, d: Object.new }] } } }
            it { expect { json }.to raise_error Babl::Errors::RenderingError, /\__root__\.a\.b\.2\.d/ }
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
            let(:object) { 42 }
            template { nav { |x| x * 2 } }

            it { expect(json).to eq(84) }
            it { expect(dependencies).to eq({}) }

            context 'block navigation breaks dependency chain' do
                template { nav { |x| x * 2 }.nav(:to_i) }
                it { expect(dependencies).to eq({}) }
            end
        end

        context '#nav should stop key propagation for #enter' do
            template { object(a: nav._) }
            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplateError }
        end
    end
end
