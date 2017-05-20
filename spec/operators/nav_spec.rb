require 'spec_helper'

describe ::Babl::Operators::Nav do
    include SpecHelper::Operators

    describe '#nav' do
        let(:template) { dsl.source { nav(:a) } }

        context 'hash navigation' do
            let(:object) { { a: 42 } }
            it { expect(json).to eq(42) }
            it { expect(dependencies).to eq(a: {}) }

            context 'block navigation propagate dependency chain' do
                let(:template) { dsl.source { nav(:a).nav(:to_i) } }
                it { expect(dependencies).to eq(a: { to_i: {} }) }
            end
        end

        context 'navigate to non serializable' do
            let(:template) { dsl.source { nav(:a) } }
            let(:object) { { a: :test } }
            it { expect { json }.to raise_error Babl::RenderingError }
        end

        context 'object navigation' do
            let(:object) { Struct.new(:a).new(42) }
            it { expect(json).to eq(42) }
            it { expect(dependencies).to eq(a: {}) }
        end

        context 'block navigation' do
            let(:object) { 42 }
            let(:template) { dsl.source { nav { |x| x * 2 } } }

            it { expect(json).to eq(84) }
            it { expect(dependencies).to eq({}) }

            context 'block navigation breaks dependency chain' do
                let(:template) { dsl.source { nav { |x| x * 2 }.nav(:to_i) } }
                it { expect(dependencies).to eq({}) }
            end
        end

        context '#nav should stop key propagation for #enter' do
            let(:template) { dsl.source { object(a: nav._) } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end
    end
end
