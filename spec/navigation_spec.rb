require 'babl'

describe ::Babl::Template do
    let(:dsl) { ::Babl::Template.new }
    let(:compiled) { template.compile }
    let(:json) { Oj.load(compiled.json(object)) }
    let(:dependencies) { compiled.dependencies }
    let(:documentation) { compiled.documentation }

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

    describe '#dep' do
        let(:template) {
            dsl.source {
                dep(a: [:b, :c]).nav(:b).dep(x: :y).nav(:z)
            }
        }

        let(:object) { { b: { z: 42 } } }

        it { expect(documentation).to eq :__value__ }
        it { expect(dependencies).to eq(a: { b: {}, c: {} }, b: { x: { y: {} }, z: {} }) }
        it { expect(json).to eq(42) }
    end

    describe '#enter' do
        context 'invalid usage' do
            let(:template) { dsl.source { enter } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'valid usage' do
            let(:template) { dsl.source { object(a: enter) } }
            let(:object) { { a: 42 } }

            it { expect(documentation).to eq(a: :__value__) }
            it { expect(dependencies).to eq(a: {}) }
            it { expect(json).to eq('a' => 42) }
        end
    end

    describe '#nav' do
        let(:template) { dsl.source { nav(:a) } }

        context 'hash navigation' do
            let(:object) { { a: 42 } }
            it { expect(json).to eq(42) }
            it { expect(dependencies).to eq(a: {}) }

            context 'block navigation propagate dependency chain' do
                let(:template) { dsl.source { nav(:a).nav(:to_i) } }
                it { expect(dependencies).to eq(a: { to_i: {} }) }
            end
        end

        context 'navigate to non serializable' do
            let(:template) { dsl.source { nav(:a) } }
            let(:object) { { a: :test } }
            it { expect { json }.to raise_error Babl::RenderingError }
        end

        context 'object navigation' do
            let(:object) { Struct.new(:a).new(42) }
            it { expect(json).to eq(42) }
            it { expect(dependencies).to eq(a: {}) }
        end

        context 'block navigation' do
            let(:object) { 42 }
            let(:template) { dsl.source { nav { |x| x * 2 } } }

            it { expect(json).to eq(84) }
            it { expect(dependencies).to eq({}) }

            context 'block navigation breaks dependency chain' do
                let(:template) { dsl.source { nav { |x| x * 2 }.nav(:to_i) } }
                it { expect(dependencies).to eq({}) }
            end
        end

        context '#nav should stop key propagation for #enter' do
            let(:template) { dsl.source { object(a: nav._) } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end
    end
end
