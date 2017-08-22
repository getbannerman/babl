# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Each do
    extend SpecHelper::OperatorTesting

    describe '#each' do
        context 'when everything is fine' do
            template { each.nav(:a) }

            let(:object) { [{ a: 3 }, { a: 2 }, { a: 1 }] }

            it { expect(json).to eq [3, 2, 1] }
            it { expect(dependencies).to eq(__each__: { a: {} }) }
            it { expect(schema).to eq s_dyn_array(s_anything) }
        end

        context 'error while navigating' do
            template { nav(:box).each.nav(:trololol) }

            let(:object) { { box: [{ trololol: 2 }, 42] } }

            it { expect { json }.to raise_error(/\__root__\.box\.1\.trololol/) }
        end

        context 'not enumerable' do
            template { nav(:lol).each }

            let(:object) { { lol: 'not enumerable' } }

            it { expect { json }.to raise_error(Babl::Errors::RenderingError, /\__root__\.lol/) }
        end

        context 'nullable array' do
            template { nullable.each.nullable.object }

            let(:object) { [1, nil] }

            it { expect(json).to eq [{}, nil] }
            it { expect(schema).to eq s_any_of(s_dyn_array(s_any_of(s_object, s_null)), s_null) }
        end
    end
end
