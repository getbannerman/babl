require 'spec_helper'

describe Babl::Operators::Merge do
    extend SpecHelper::OperatorTesting

    describe '#merge' do
        context 'merge two objects' do
            template {
                merge(
                    object(a: static('A')),
                    b: _
                )
            }

            let(:object) { { b: 42 } }

            it { expect(json).to eq('a' => 'A', 'b' => 42) }
            it { expect(dependencies).to eq(b: {}) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:a, s_static('A')),
                        s_property(:b, s_anything)
                    )
                )
            }
        end

        context 'merge inside object' do
            template { object(toto: merge(_, lol: 42)) }

            let(:object) { { toto: { cool: 'ouai' } } }

            it { expect(json).to eq('toto' => { 'lol' => 42, 'cool' => 'ouai' }) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:toto,
                            s_object(
                                s_property(:lol, s_static(42)),
                                additional: true
                            ))
                    )
                )
            }
        end

        context 'merge nothing' do
            template { merge }

            it { expect(json).to eq({}) }
            it { expect(schema).to eq s_object }
        end

        context 'merge that could fail in some case' do
            template {
                merge(
                    switch(
                        false => switch(
                            true => {},
                            default => 'not an object'
                        ),
                        default => {}
                    ),
                    object(test: 1)
                )
            }

            it { expect { schema }.to raise_error Babl::Errors::InvalidTemplateError }
        end

        context 'merge only one static value' do
            template { merge(42) }

            it { expect { schema }.to raise_error Babl::Errors::InvalidTemplateError }
        end

        context 'merge only one dynamic value' do
            template { merge(itself) }

            let(:object) { 43 }

            it { expect { json }.to raise_error Babl::Errors::RenderingError }
            it { expect(schema).to eq s_object(additional: true) }
        end

        context 'merge object with static' do
            template { merge(object(a: 1), static(b: 2)) }

            it { expect(json).to eq('a' => 1, 'b' => 2) }
            it { expect(schema).to eq s_object(s_property(:a, s_static(1)), s_property(:b, s_static(2))) }
        end

        context 'merge object with conditionally present properties' do
            template {
                merge(
                    switch(
                        itself => object(a: 1, b: 2),
                        default => object(b: 3, c: 4)
                    ),
                    itself,
                    switch(
                        itself => object(c: 7),
                        default => object(c: 5)
                    )
                )
            }

            let(:object) { { b: 1 } }

            it { expect(json).to eq('a' => 1, 'b' => 1, 'c' => 7) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:a, s_any_of(s_anything, s_static(1)), required: false),
                        s_property(:b, s_any_of(s_anything, s_static(2), s_static(3))),
                        s_property(:c, s_any_of(s_static(7), s_static(5))),
                        additional: true
                    )
                )
            }
        end
    end
end
