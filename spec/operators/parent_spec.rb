require 'spec_helper'

describe ::Babl::Operators::Parent do
    include SpecHelper::Operators

    describe '#parent' do
        context 'valid usage' do
            let(:template) {
                dsl.source {
                    nav(:box).dep(:box_dep).parent.dep(:root_dep)
                }
            }

            let(:object) { { box: 42 } }

            it { expect(documentation).to eq :__value__ }
            it { expect(dependencies).to eq(box: { box_dep: {} }, root_dep: {}) }
            it { expect(json).to eq('box' => 42) }
        end

        context 'error while navigating' do
            let(:object) { { a: { b: { c: 56 } } } }
            let(:template) { dsl.source { nav(:a).parent.nav(:a).nav(:b, :x) } }

            it { expect { json }.to raise_error(/\__root__\.a\.b\.x/) }
        end

        context 'invalid usage' do
            let(:template) { dsl.source { parent } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'deeply nested parent chain' do
            let(:template) {
                dsl.source {
                    nav(:a, :b, :c, :d, :e).parent.parent.parent.nav(:f, :g, :h).parent.parent.parent.parent.nav(:i)
                }
            }
            it { expect(dependencies).to eq(a: { b: { f: { g: { h: {} } }, c: { d: { e: {} } } }, i: {} }) }
        end

        context 'same-level key + nested parent chain' do
            let(:template) {
                dsl.source {
                    object(
                        a: _.nav(:b, :c).parent.parent.nav(:h),
                        b: _.nav(:a).parent.nav(:a)
                    )
                }
            }
            it { expect(dependencies).to eq(a: { b: { c: {} }, h: {} }, b: { a: {} }) }
        end
    end
end
