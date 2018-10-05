# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::With do
    extend SpecHelper::OperatorTesting

    describe '#with' do
        context 'everything is fine' do
            template {
                object(
                    result: with(
                        unscoped,
                        nav(:msg),
                        _.parent.nav(:msg).dep(:lol)
                    ) { |obj, a, b| "#{a} #{b} #{obj[:msg]}" }
                )
            }

            let(:object) { { result: 42, msg: 'Hello C' } }

            it { expect(json).to eq('result' => 'Hello C Hello C Hello C') }
            it { expect(dependencies).to eq(msg: { lol: {} }) }
            it { expect(schema).to eq s_object(s_property(:result, s_anything)) }
        end

        context 'with followed by constant' do
            template { with(nav(:a), nav(:b)) { |a, b| a + b }.static(2) }

            it { expect(json).to eq 2 }
            it { expect(dependencies).to eq({}) }
        end

        context 'when the templates are constants' do
            template {
                with(
                    switch(true => 42),
                    'test'
                ) { |val1, val2| val1 + val2.size }
            }

            it { expect(json).to eq 46 }
        end

        context 'when the templates are constants and the block fails during compilation' do
            template {
                with(1) { |_| raise 'oops' }
            }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'when an input template fails during rendering' do
            template {
                nav(:a).with(nav(:b).call { raise 'oops' }) { |_| }
            }

            let(:object) { { a: { b: 1 } } }

            it { expect { json }.to raise_error "oops\nBABL @ __root__.a.b.__block__" }
        end

        context 'when the rest of the chain fails during rendering' do
            template {
                with(nav(:a), &:itself).nav(:b).call { raise 'oops' }
            }

            let(:object) { { a: { b: 1 } } }

            it { expect { json }.to raise_error "oops\nBABL @ __root__.__block__.b.__block__" }
        end

        context 'with + parent + nav' do
            template { with { 3 }.dep(:ignored_dep).parent.nav(:a) }

            let(:object) { { a: 1 } }

            it { expect(json).to eq 1 }
            it { expect(dependencies).to eq(a: {}) }
            it { expect(unoptimized_dependencies).to eq(a: {}) }
        end

        context 'when the block raise an exception' do
            template { with { raise 'lol' } }

            it { expect { json }.to raise_error(/\__root__\.__block__/) }
        end
    end
end
