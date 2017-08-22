# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Null do
    extend SpecHelper::OperatorTesting

    describe '#null' do
        template { { val: null } }

        let(:object) { {} }

        it { expect(schema).to eq s_object(s_property(:val, s_static(nil))) }
        it { expect(dependencies).to eq({}) }
        it { expect(json).to eq('val' => nil) }
    end
end
