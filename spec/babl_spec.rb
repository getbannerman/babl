# frozen_string_literal: true
require 'spec_helper'

describe Babl do
    subject { compiled.render(nil) }

    describe '#compile' do
        context 'block' do
            let(:compiled) { Babl.compile { static(1) } }
            it { is_expected.to eq 1 }
        end

        context 'template' do
            let(:compiled) { Babl.compile(Babl.template.static(1)) }
            it { is_expected.to eq 1 }
        end
    end

    describe Babl::AbsoluteLookupContext do
        let(:lookup_context) { described_class.new(File.dirname(__FILE__)) }
        let(:compiled) { Babl.source { partial('test_template') }.compile(lookup_context: lookup_context) }

        it { is_expected.to eq(this_is_a: 'test') }
    end
end
