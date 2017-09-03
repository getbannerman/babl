# frozen_string_literal: true
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
                        s_property(:a, s_primitive('A')),
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
                                s_property(:lol, s_primitive(42)),
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
                        -> { false } => switch(
                            -> { true } => {},
                            default => 'not an object'
                        ),
                        default => {}
                    ),
                    object(test: 1)
                )
            }

            it { expect { schema }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'merge only one static value' do
            template { merge(42) }

            it { expect { schema }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'merge only nil' do
            template { merge(nil) }

            it { expect(schema).to eq s_object }
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
            it { expect(schema).to eq s_object(s_property(:a, s_primitive(1)), s_property(:b, s_primitive(2))) }
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
                        s_property(:a, s_anything, required: false),
                        s_property(:b, s_anything),
                        s_property(:c, s_any_of(s_primitive(7), s_primitive(5))),
                        additional: true
                    )
                )
            }
        end

        context 'overriding properties while merging objects' do
            template {
                merge(
                    merge(
                        object(a: _, b: _, c: _),
                        merge(merge(object(a: 1))),
                        object(c: 2)
                    )
                )
            }

            let(:object) { { b: 5 } }

            it { expect(dependencies).to eq(b: {}) }
            it { expect(json).to eq('a' => 1, 'b' => 5, 'c' => 2) }

            it {
                expect(schema).to eq s_object(
                    s_property(:a, s_primitive(1)),
                    s_property(:b, s_anything),
                    s_property(:c, s_primitive(2))
                )
            }
        end

        context 'switch between objects generate a single object doc' do
            template {
                switch(
                    itself => merge(itself, object(a: 1, b: 2, d: 4)),
                    default => { c: string, d: 4 }
                )
            }

            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:a, s_primitive(1), required: false),
                        s_property(:b, s_primitive(2), required: false),
                        s_property(:c, s_string, required: false),
                        s_property(:d, s_primitive(4), required: true),
                        additional: true
                    )
                )
            }
        end

        context 'switch between disjoint objects' do
            template {
                switch(
                    -> {} => { a: 1 },
                    -> {} => { b: 3 }
                )
            }

            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:a, s_primitive(1), required: false),
                        s_property(:b, s_primitive(3), required: false)
                    )
                )
            }
        end
    end
end
