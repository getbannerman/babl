# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Partial do
    extend SpecHelper::OperatorTesting

    before {
        stub_const('MyExt', Module.new {
            def say_hello
                source { 'hello' }
            end
        })
    }

    let(:lookup_context) {
        TestLookupContext.new(
            blabla: TestLookupContext.new(
                "[{x: _.partial('navi')}, partial('muche')]",
                muche: TestLookupContext.new('23'),
                navi: TestLookupContext.new(
                    "using(MyExt) { partial('navi') }",
                    navi: TestLookupContext.new(
                        "partial('miche')",
                        miche: TestLookupContext.new(
                            "partial('blabla')",
                            blabla: TestLookupContext.new('[say_hello, call { 1 + self }]')
                        )
                    )
                )
            )
        )
    }

    let(:object) { { x: 12 } }

    context 'missing partial' do
        template { partial('i_do_not_exist') }

        it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
    end

    context 'found partial' do
        template { partial('blabla') }

        it { expect(json).to eq [{ 'x' => ['hello', 13] }, 23] }
    end
end
