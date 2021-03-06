# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Enter do
    extend SpecHelper::OperatorTesting

    describe '#enter' do
        context 'invalid usage' do
            template { enter }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'valid usage' do
            template { object(a: enter) }

            let(:object) { { a: 42 } }

            it { expect(schema).to eq(s_object(s_property(:a, s_anything))) }
            it { expect(dependencies).to eq(a: {}) }
            it { expect(json).to eq('a' => 42) }

            context 'using alias' do
                template { object(a: _) }
                it { expect(json).to eq('a' => 42) }
            end
        end

        context '_? variant' do
            template { object(a: _?, 'b' => _?) }

            let(:object) { { a?: 2, 'b?' => 1 } }

            it { expect(json).to eq('a' => 2, 'b' => 1) }
            it { expect(dependencies).to eq(a?: {}, 'b?' => {}) }
        end
    end
end
