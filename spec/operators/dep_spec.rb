require 'spec_helper'

describe ::Babl::Operators::Dep do
    include SpecHelper::Operators

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
end
