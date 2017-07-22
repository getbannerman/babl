require 'babl/utils'

describe Babl::Utils::Value do
    let(:clazz) { described_class.new(:val1) }
    let(:inst1) { clazz.new([1]) }
    let(:inst2) { clazz.new([1]) }

    it { expect(inst1).to eq inst2 }
    it { expect(inst1).to eql inst2 }
    it { expect(inst1.hash).to eq inst2.hash }

    describe 'immutability' do
        it { expect { inst1.val1 = 2 }.to raise_error ::RuntimeError }
    end

    describe 'test when not equal' do
        before { inst2.val1 << 3 }

        it { expect(inst1).not_to eq inst2 }
        it { expect(inst1.hash).to eq inst2.hash }
    end

    describe 'use hash for equality test' do
        let(:inst1dup) { inst1.dup }

        it { expect(inst1dup).to eq inst1 }

        context do
            before { inst1dup._cached_hash = 42 }
            it { expect(inst1dup).not_to eq inst1 }
            it { expect(inst1dup).not_to eq inst2 }
        end
    end

    describe 'ensure eql? behavior' do
        let(:inst1) { clazz.new(1.0) }
        let(:inst2) { clazz.new(1) }

        it { expect(inst1).not_to eql inst2 }
        it { expect(inst1).not_to eq inst2 }
    end

    describe 'no property' do
        let(:clazz1) { described_class.new }
        let(:clazz2) { described_class.new }

        let(:clazz1_inst1) { clazz1.new }
        let(:clazz1_inst2) { clazz1.new }
        let(:clazz2_inst1) { clazz2.new }

        it { expect(clazz1_inst1).to eq clazz1_inst2 }
        it { expect(clazz1_inst1).not_to eq clazz2_inst1 }
    end
end
