require 'spec_helper'

describe ::Babl::Operators::Nullable do
    include SpecHelper::Operators

    describe '#nullable' do
        let(:object) { { nullprop: nil, notnullprop: { abc: 12 } } }

        let(:template) {
            dsl.source {
                object(
                    nullprop: nav(:nullprop).nullable.nav(:abc),
                    notnullprop: nav(:notnullprop).nullable.nav(:abc)
                )
            }
        }

        it { expect(json).to eq('nullprop' => nil, 'notnullprop' => 12) }

        it {
            expect(documentation).to eq(
                notnullprop: { "Case 1": nil, "Case 2": :__value__ },
                nullprop: { "Case 1": nil, "Case 2": :__value__ }
            )
        }

        it { expect(dependencies).to eq(nullprop: { abc: {} }, notnullprop: { abc: {} }) }
    end
end
