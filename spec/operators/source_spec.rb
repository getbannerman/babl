# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Source do
    extend SpecHelper::OperatorTesting

    describe '#source' do
        let(:object) { { abc: { def: 12 } } }

        context 'block returning primitive' do
            template { source { true } }

            it { expect(json).to eq(true) }
        end

        context 'block using operators' do
            template { source { static(3) } }

            it { expect(json).to eq(3) }
        end

        context 'two level sourcing' do
            template { source { nav(:abc).source { nav(:def) } } }

            it { expect(json).to eq(12) }
        end

        context 'string template' do
            template { source('object(a: static(true))', 'file.rb', 3) }

            it { expect(json).to eq('a' => true) }
        end

        context 'both string & block template' do
            template { source('object(a: static(true))', 'file.rb', 3) { 1 } }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'source used without argument' do
            template { source }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context "access to block's context" do
            template { source { object(value: value) } }
            let(:value) { 42 }

            it { expect(json).to eq('value' => 42) }
        end

        context "check existence of methods in block's context" do
            template {
                tpl = self
                666.instance_eval {
                    tpl.source {
                        {
                            non_existing_method: respond_to?(:non_existing_method),
                            rationalize: respond_to?(:rationalize),
                            method_rationalize_nil: method(:rationalize).nil?
                        }
                    }
                }
            }

            it {
                expect(json).to eq(
                    'rationalize' => true,
                    'non_existing_method' => false,
                    'method_rationalize_nil' => false
                )
            }
        end

        context 'dsl proxy as template' do
            template { source { self } }

            it { expect(json).to eq('abc' => { 'def' => 12 }) }
        end
    end
end
