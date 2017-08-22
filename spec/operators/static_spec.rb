# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Static do
    extend SpecHelper::OperatorTesting

    describe '#static' do
        context 'static object' do
            template { static('1': 'cava') }

            it { expect(json).to eq('1' => 'cava') }
            it { expect(dependencies).to eq({}) }
            it { expect(schema).to eq s_object(s_property(:'1', s_static('cava'))) }
        end

        context 'static primitive' do
            template { static('ok') }

            it { expect(schema).to eq s_static('ok') }
        end

        context 'invalid' do
            template { static(test: Object.new) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end
    end
end
