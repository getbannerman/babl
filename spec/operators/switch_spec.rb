# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Switch do
    extend SpecHelper::OperatorTesting

    describe '#switch' do
        context 'realistic use case' do
            template {
                even = nullable.nav(:even?)
                odd = nullable.nav(:odd?)

                each.switch(
                    even => nav { |x| "#{x} is even" },
                    odd => nav { |x| "#{x} is odd" },
                    default => continue
                ).static('WTF')
            }

            let(:object) { [1, 2, nil, 5] }

            it { expect(json).to eq ['1 is odd', '2 is even', 'WTF', '5 is odd'] }
            it { expect(dependencies).to eq(__each__: { even?: {}, odd?: {} }) }
            it { expect(schema).to eq s_dyn_array(s_anything) }
        end

        context 'static condition' do
            template { switch(true => 42) }

            let(:object) { {} }

            it { expect(json).to eq 42 }
        end

        context 'only one output possible' do
            template { switch(-> {} => 2, -> {} => 2) }

            it { expect(schema).to eq s_primitive(2) }
        end

        context 'no branch taken' do
            template { switch(-> { false } => 1) }

            let(:object) { { abc: { lol: { ok: 42 } } } }

            it { expect(dependencies).to eq({}) }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end

        context 'no branch takable' do
            template { switch(false => 1) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'non serializable objects are allowed internally' do
            template { switch(nav(:test) => 42) }

            let(:object) { { test: Object.new } }

            it { expect(json).to eq 42 }
        end

        context 'switch between empty array and a dyn array' do
            template { switch(itself => each.object(a: 1), default => []) }

            let(:object) { [nil] }

            it { expect(json).to eq(['a' => 1]) }
            it { expect(schema).to eq s_dyn_array(s_object(s_property(:a, s_primitive(1)))) }
        end

        context 'switch between fixed array and a dyn array producing different output' do
            template { switch(-> {} => each.static(1), -> {} => [2]) }

            it {
                expect(schema).to eq s_any_of(
                    s_dyn_array(s_primitive(1)), s_fixed_array(s_primitive(2))
                )
            }
        end

        context 'switch between fixed array and a dyn array producing identical output' do
            template { switch(-> {} => nullable.each.static(1), -> {} => [1]) }

            it { expect(schema).to eq s_any_of(s_null, s_dyn_array(s_primitive(1))) }
        end

        context 'switch between similar objects having only one different property' do
            template {
                switch(
                    -> {} => { a: 34, b: string },
                    -> {} => { a: 34, b: integer },
                    -> {} => { b: boolean, a: 34 }
                )
            }

            it {
                expect(schema).to eq s_object(
                    s_property(:a, s_primitive(34)),
                    s_property(:b, s_any_of(s_string, s_integer, s_boolean))
                )
            }
        end

        context 'switch between similar objects having more than one different property' do
            template { switch(-> {} => { a: 35, b: 1 }, -> {} => { a: 34, b: 2 }) }

            it {
                expect(schema).to eq s_any_of(
                    s_object(
                        s_property(:a, s_primitive(35)),
                        s_property(:b, s_primitive(1))
                    ),
                    s_object(
                        s_property(:a, s_primitive(34)),
                        s_property(:b, s_primitive(2))
                    )
                )
            }
        end

        context 'switch between two possible dyn arrays' do
            template {
                switch(
                    -> {} => each.static('a'),
                    -> {} => each.static('b'),
                    -> {} => nullable.each.static('c')
                )
            }

            it {
                expect(schema).to eq s_any_of(
                    s_null,
                    s_dyn_array(s_any_of(s_primitive('a'), s_primitive('c'), s_primitive('b')))
                )
            }
        end

        context 'switch between true and false' do
            template { switch(-> {} => true, -> {} => false) }
            it { expect(schema).to eq s_boolean }
        end

        context 'switch with a duplicated condition' do
            template {
                switch(
                    nav(:abc) => 1,
                    nav(:def) => 2,
                    nav(:abc) => 3,
                    default => 4
                )
            }
            it {
                expect(schema).to eq s_any_of(
                    s_primitive(1),
                    s_primitive(2),
                    s_primitive(4)
                )
            }
        end

        context 'switch between true and a string' do
            template { switch(-> {} => true, -> {} => string) }
            it { expect(schema).to eq s_any_of(s_primitive(true), s_string) }
        end

        context 'switch between any string and a specific string' do
            template { switch(-> {} => string, -> {} => 'lol') }
            it { expect(schema).to eq s_string }
        end

        context 'switch between anything and a number' do
            template { switch(-> {} => number, -> {} => itself) }
            it { expect(schema).to eq s_anything }
        end

        context 'switch between any boolean and a specific boolean' do
            template { switch(-> {} => boolean, -> {} => true) }
            it { expect(schema).to eq s_boolean }
        end

        context 'switch between a specific float, specific integer and any number' do
            template { switch(-> {} => 1.2, -> {} => 2, -> {} => number) }
            it { expect(schema).to eq s_number }
        end

        context 'switch between a specific float, specific integer and any integer' do
            template { switch(-> {} => 1.2, -> {} => 2, -> {} => integer) }
            it { expect(schema).to eq s_any_of(s_integer, s_primitive(1.2)) }
        end

        context 'switch producing always the same output and having default value' do
            template {
                switch(
                    nav(:b) => object(a: _),
                    default => object(a: _)
                )
            }
            it { expect(schema).to eq s_object(s_property(:a, s_anything)) }
            it { expect(dependencies).to eq(a: {}) }
        end

        context 'switch with a condition after the default' do
            template {
                switch(
                    nav(:b) => 1,
                    default => 2,
                    nav(:c) => 3
                )
            }
            it { expect(schema).to eq s_any_of(s_primitive(1), s_primitive(2)) }
            it { expect(dependencies).to eq(b: {}) }
        end

        context 'switch with a falsy condition' do
            template {
                switch(
                    nav(:b) => 1,
                    false => 2,
                    nav(:c) => 3
                )
            }
            it { expect(schema).to eq s_any_of(s_primitive(1), s_primitive(3)) }
            it { expect(dependencies).to eq(b: {}, c: {}) }
        end

        context 'switch between objects with discriminator' do
            template { switch(-> {} => { type: 'a', v: string }, -> {} => { type: 'b', v: integer }) }

            it {
                expect(schema).to eq s_any_of(
                    s_object(
                        s_property(:type, s_primitive('a')),
                        s_property(:v, s_string)
                    ),
                    s_object(
                        s_property(:type, s_primitive('b')),
                        s_property(:v, s_integer)
                    )
                )
            }
        end

        context 'chained switches' do
            template {
                nullable.switch(
                    null? => nav(:a),
                    -> { true } => nav(:b)
                )
            }

            let(:object) { { a: 1, b: 2 } }

            it { expect(dependencies).to eq(b: {}) }
            it { expect(unoptimized_dependencies).to eq(a: {}, b: {}) }
            it { expect(json).to eq 2 }
        end

        context 'with dependencies' do
            template { nav(:test).switch(nav(:keke) => parent.nav(:lol)) }
            it { expect(dependencies).to eq(test: { keke: {} }, lol: {}) }
        end
    end
end
