# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Object do
    extend SpecHelper::OperatorTesting

    describe '#object' do
        template { object(:a, :b, c: _, d: nav(:d)) }

        let(:object) { { a: 1, b: 2, c: 3, d: 4 } }

        it { expect(json).to eq('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4) }
        it {
            expect(schema).to eq(
                s_object(
                    s_property(:a, s_anything),
                    s_property(:b, s_anything),
                    s_property(:c, s_anything),
                    s_property(:d, s_anything)
                )
            )
        }
        it { expect(dependencies).to eq(a: {}, b: {}, c: {}, d: {}) }

        context 'misused (chaining after object)' do
            template { object(:a).object(:b) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'template containing a constant object' do
            template {
                object(
                    a: _,
                    tpl: [{
                        p1: [45],
                        p2: switch(
                            default => 1,
                            default => continue
                        )
                    }]
                )
            }

            let(:render1) { compiled.render(object) }
            let(:render2) { compiled.render(object) }

            it {
                expect(json).to eq(
                    'a' => 1,
                    'tpl' => [{
                        'p1' => [45],
                        'p2' => 1
                    }]
                )
            }

            it { expect(render1).to eq render2 }
            it { expect(render1[:tpl]).to equal render2[:tpl] }
            it { expect(render1).not_to equal render2 }
        end
    end
end
