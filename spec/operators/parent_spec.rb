# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Parent do
    extend SpecHelper::OperatorTesting

    describe '#parent' do
        context 'valid usage' do
            template { nav(:box).dep(:box_dep).parent.dep(:root_dep) }

            let(:object) { { box: 42 } }

            it { expect(schema).to eq s_anything }
            it { expect(dependencies).to eq(box: { box_dep: {} }, root_dep: {}) }
            it { expect(json).to eq('box' => 42) }
        end

        context 'error while navigating' do
            template { nav(:a).parent.nav(:a).nav(:b, :x) }

            let(:object) { { a: { b: { c: 56 } } } }

            it { expect { json }.to raise_error(/\__root__\.a\.b\.x/) }
        end

        context 'invalid usage' do
            template { parent }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'deeply nested parent chain' do
            template {
                nav(:a, :b, :c, :d, :e).parent.parent.parent.nav(:f, :g, :h).parent.parent.parent.parent.nav(:i)
            }

            it { expect(dependencies).to eq(a: { b: { f: { g: { h: {} } }, c: { d: { e: {} } } }, i: {} }) }
        end

        context 'parent followed by constant' do
            template { nav(:a).call([parent.static(1)]) }

            it { expect(json).to eq([1]) }
        end

        context 'same-level key + nested parent chain' do
            template {
                object(
                    a: _.nav(:b, :c).parent.parent.nav(:h),
                    b: _.nav(:a).parent.nav(:a)
                )
            }

            it { expect(dependencies).to eq(a: { b: { c: {} }, h: {} }, b: { a: {} }) }
        end
    end
end
