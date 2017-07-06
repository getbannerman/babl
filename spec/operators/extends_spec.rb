require 'spec_helper'

describe ::Babl::Operators::Extends do
    include SpecHelper::Operators

    let(:custom_lookup_context) {
        TestLookupContext.new(base_partial: TestLookupContext.new('object(a: 1, b: 3)'))
    }
    let(:ctx_dsl) { dsl.with_lookup_context(custom_lookup_context) }
    let(:object) { [nil] }

    context 'simple use case' do
        let(:template) { ctx_dsl.source { each.extends('base_partial', object(x: 1), b: 34) } }
        it { expect(json).to eq(['a' => 1, 'x' => 1, 'b' => 34]) }
    end
end
