require 'spec_helper'

describe ::Babl::Operators::Null do
    include SpecHelper::Operators

    describe '#null' do
        let(:template) { dsl.source { { val: null } } }
        let(:object) { {} }

        it { expect(documentation).to eq(val: nil) }
        it { expect(dependencies).to eq({}) }
        it { expect(json).to eq('val' => nil) }
    end
end
