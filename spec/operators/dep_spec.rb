# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Dep do
    extend SpecHelper::OperatorTesting

    describe '#dep' do
        template { dep(a: %i[b c]).nav(:b).dep('x' => :y).nav(:z) }

        let(:object) { { b: { z: 42 } } }

        it { expect(schema).to eq s_anything }
        it { expect(dependencies).to eq(a: { b: {}, c: {} }, b: { 'x' => { y: {} }, z: {} }) }
        it { expect(json).to eq(42) }
    end
end
