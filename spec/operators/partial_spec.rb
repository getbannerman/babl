require 'spec_helper'

describe ::Babl::Operators::Partial do
    include SpecHelper::Operators

    let(:custom_lookup_context) {
        TestLookupContext.new(
            blabla: TestLookupContext.new(
                "[partial('navi').partial('miche'), partial('muche')]",

                miche: TestLookupContext.new(
                    "partial('blabla')",

                    blabla: TestLookupContext.new('call { 1 + self }')
                ),

                muche: TestLookupContext.new('23'),
                navi: TestLookupContext.new(':some_property')
            )
        )
    }
    let(:ctx_dsl) { dsl.with_lookup_context(custom_lookup_context) }
    let(:object) { { some_property: 12 } }

    context 'missing partial' do
        let(:template) { ctx_dsl.partial('i_do_not_exist') }
        it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
    end

    context 'found partial' do
        let(:template) { ctx_dsl.partial('blabla') }
        it { expect(json).to eq [13, 23] }
    end
end
