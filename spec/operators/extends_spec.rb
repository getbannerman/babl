require 'spec_helper'

describe Babl::Operators::Extends do
    extend SpecHelper::OperatorTesting

    let(:custom_lookup_context) {
        TestLookupContext.new(
            object_partial: TestLookupContext.new('object(a: 1, b: 3)'),
            string_partial: TestLookupContext.new('"lol"')
        )
    }
    let(:dsl) { Babl::Template.new.with_lookup_context(custom_lookup_context) }
    let(:object) { [nil] }

    context 'simple use case' do
        template { each.extends('object_partial', object(x: 1), b: 34) }
        it { expect(json).to eq(['a' => 1, 'x' => 1, 'b' => 34]) }
    end

    context 'extend a non-object' do
        template { extends('string_partial') }
        it { expect(json).to eq('lol') }
        it { expect(schema).to eq s_static('lol') }
    end

    context 'extend a non-object and try to add properties' do
        template { each.extends('string_partial', test: 1) }
        it { expect { schema }.to raise_error Babl::Errors::InvalidTemplate }
    end
end
