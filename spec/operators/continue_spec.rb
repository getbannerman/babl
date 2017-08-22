# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Continue do
    extend SpecHelper::OperatorTesting

    describe '#switch' do
        context 'navigation before continue' do
            template { nav(:abc).switch(false => 1, default => nav(:lol).continue).object(val: nav(:ok)) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'continue without switch' do
            template { continue }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'continue in sub-object' do
            template { object(a: switch(default => object(x: continue))) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end
    end
end
