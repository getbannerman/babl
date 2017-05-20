require 'spec_helper'

describe ::Babl::Operators::Static do
    include SpecHelper::Operators

    describe '#static' do
        let(:template) { dsl.source { static('1': 'cava') } }
        let(:object) { nil }

        it { expect(json).to eq('1' => 'cava') }
        it { expect(dependencies).to eq({}) }
        it { expect(documentation).to eq('1': 'cava') }

        context 'invalid' do
            let(:template) { dsl.source { static(test: Object.new) } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end
    end
end
