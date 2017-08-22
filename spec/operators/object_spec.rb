# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Object do
    extend SpecHelper::OperatorTesting

    describe '#object' do
        template { object(:a, :b, c: _, d: nav(:d)) }

        let(:object) { { a: 1, b: 2, c: 3, d: 4 } }

        it { expect(json).to eq('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4) }
        it {
            expect(schema).to eq(
                s_object(
                    s_property(:a, s_anything),
                    s_property(:b, s_anything),
                    s_property(:c, s_anything),
                    s_property(:d, s_anything)
                )
            )
        }
        it { expect(dependencies).to eq(a: {}, b: {}, c: {}, d: {}) }

        context 'misused (chaining after object)' do
            template { object(:a).object(:b) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end
    end
end
