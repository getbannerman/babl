require 'spec_helper'

describe Babl::Operators::Nullable do
    extend SpecHelper::OperatorTesting

    describe '#nullable' do
        let(:object) { { nullprop: nil, notnullprop: { abc: 12 } } }

        template {
            object(
                nullprop: nav(:nullprop).nullable.nav(:abc),
                notnullprop: nav(:notnullprop).nullable.object(:abc)
            )
        }

        it { expect(json).to eq('nullprop' => nil, 'notnullprop' => { 'abc' => 12 }) }

        it {
            expect(schema).to eq(
                s_object(
                    s_property(:nullprop, s_anything),
                    s_property(:notnullprop, s_any_of(s_object(s_property(:abc, s_anything)), s_null))
                )
            )
        }

        it { expect(dependencies).to eq(nullprop: { abc: {} }, notnullprop: { abc: {} }) }
    end
end
