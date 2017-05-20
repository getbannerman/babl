require 'spec_helper'

describe ::Babl::Operators::Each do
    include SpecHelper::Operators

    describe '#each' do
        context 'when everything is fine' do
            let(:template) { dsl.source { each.nav(:a) } }
            let(:object) { [{ a: 3 }, { a: 2 }, { a: 1 }] }

            it { expect(json).to eq [3, 2, 1] }
            it { expect(dependencies).to eq(__each__: { a: {} }) }
            it { expect(documentation).to eq [:__value__] }
        end

        context 'error while navigating' do
            let(:object) { { box: [{ trololol: 2 }, 42] } }
            let(:template) { dsl.source { nav(:box).each.nav(:trololol) } }

            it { expect { json }.to raise_error(/\__root__\.box\.1\.trololol/) }
        end
    end
end
