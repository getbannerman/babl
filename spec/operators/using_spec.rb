# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Using do
    extend SpecHelper::OperatorTesting

    let(:object) { { a: 1, b: 2 } }

    before {
        stub_const('MyExtA', Module.new {
            def nav_a
                nav(:a)
            end
        })
        stub_const('MyExtB', Module.new {
            def nav_b
                nav(:b)
            end
        })
    }

    describe '#using' do
        context 'just call using' do
            template { using(MyExtA) }
            it { expect(json).to eq('a' => 1, 'b' => 2) }
        end

        context 'using nothing' do
            template { using.static('ok') }
            it { expect(json).to eq('ok') }
        end

        context 'call custom op' do
            template { using(MyExtA).nav_a }
            it { expect(json).to eq(1) }
        end

        context 'use two operator, separately' do
            template { using(MyExtA).nav_a.parent.using(MyExtB) { array(nav_b, nav_a) } }
            it { expect(json).to eq [2, 1] }
        end
    end
end
