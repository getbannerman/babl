require 'spec_helper'

describe Babl::Operators::Array do
    extend SpecHelper::OperatorTesting

    describe '#array' do
        context 'statically defined array' do
            template { array('coucou', 45, a: 1, b: [_]) }

            let(:object) { { b: 12 } }

            it { expect(json).to eq ['coucou', 45, { 'a' => 1, 'b' => [12] }] }
            it { expect(dependencies).to eq(b: {}) }
            it {
                expect(schema).to eq(
                    s_fixed_array(
                        s_static('coucou'),
                        s_static(45),
                        s_object(
                            s_property(:a, s_static(1)),
                            s_property(:b, s_fixed_array(s_anything))
                        )
                    )
                )
            }
        end

        context 'nullable array' do
            template { nullable.array(itself) }

            let(:object) { 1 }

            it { expect(json).to eq([1]) }
            it { expect(schema).to eq s_fixed_array(s_anything, nullable: true) }
        end
    end
end
