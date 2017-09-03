# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::IsNull do
    extend SpecHelper::OperatorTesting

    template { null? }

    it { expect(schema).to eq s_boolean }

    context 'nil' do
        let(:object) { nil }

        it { expect(json).to eq true }
    end

    context 'is not nil' do
        let(:object) { false }

        it { expect(json).to eq false }
    end
end
