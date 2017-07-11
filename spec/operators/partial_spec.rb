require 'spec_helper'

describe Babl::Operators::Partial do
    extend SpecHelper::OperatorTesting

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
    let(:dsl) { Babl::Template.new.with_lookup_context(custom_lookup_context) }
    let(:object) { { some_property: 12 } }

    context 'missing partial' do
        template { partial('i_do_not_exist') }

        it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplateError }
    end

    context 'found partial' do
        template { partial('blabla') }

        it { expect(json).to eq [13, 23] }
    end
end
