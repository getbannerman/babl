# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Default do
    extend SpecHelper::OperatorTesting

    describe '#default' do
        template { default }

        it { expect(json).to eq true }
        it { expect(schema).to eq s_primitive(true) }
        it { expect(dependencies).to eq({}) }
    end
end
