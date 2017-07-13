require 'spec_helper'

describe Babl::Operators::Typed do
    extend SpecHelper::OperatorTesting

    describe '#integer' do
        template { [integer] }

        it { expect(schema).to eq s_fixed_array(s_integer) }

        context do
            let(:object) { 12 }
            it { expect(json).to eq [12] }
        end

        context do
            let(:object) { 12.5 }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end
    end

    describe '#number' do
        template { [number] }

        it { expect(schema).to eq s_fixed_array(s_number) }

        context do
            let(:object) { 12 }
            it { expect(json).to eq [12] }
        end

        context do
            let(:object) { 12.5 }
            it { expect(json).to eq [12.5] }
        end

        context do
            let(:object) { '12' }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end
    end

    describe '#string' do
        template { [string] }

        it { expect(schema).to eq s_fixed_array(s_string) }

        context do
            let(:object) { [12] }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end

        context do
            let(:object) { '12' }
            it { expect(json).to eq ['12'] }
        end
    end

    describe '#boolean' do
        template { [boolean] }

        it { expect(schema).to eq s_fixed_array(s_boolean) }

        context do
            let(:object) { true }
            it { expect(json).to eq [true] }
        end

        context do
            let(:object) { false }
            it { expect(json).to eq [false] }
        end

        context do
            let(:object) { 'true' }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end
    end

    context 'obviously invalid template' do
        template { integer.string }
        it { expect { schema }.to raise_error Babl::Errors::InvalidTemplate }
    end
end
