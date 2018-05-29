# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Pin do
    extend SpecHelper::OperatorTesting

    describe '#pin' do
        context 'simple pinning' do
            template {
                nav(:a).pin { |a|
                    nav(:b).object(
                        x: _,
                        y: a.nav(:y)
                    )
                }
            }

            let(:object) {
                { a: { b: { x: 42 }, y: 13 } }
            }

            it { expect(json).to eq('x' => 42, 'y' => 13) }
            it { expect(dependencies).to eq(a: { y: {}, b: { x: {} } }) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:x, s_anything),
                        s_property(:y, s_anything)
                    )
                )
            }
        end

        context 'named pin' do
            template { nav(:prop).named_pin(:pouet).parent.nav(:prop3).goto_pin(:pouet).nav(:prop2) }
            let(:object) { { prop: { prop2: 42 }, prop3: 3 } }

            it { expect(json).to eq 42 }
            it { expect(dependencies).to eq(prop: { prop2: {} }, prop3: {}) }
            it { expect(unoptimized_dependencies).to eq(prop: { prop2: {} }, prop3: {}) }
            it { expect(schema).to eq s_anything }
        end

        context 'non existing pin' do
            template { named_pin(:b).goto_pin(:a) }
            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'un-used pin' do
            template {
                pin(:oki) { |ref|
                    switch(
                        false => ref,
                        default => 34
                    )
                }
            }

            it { expect(json).to eq 34 }
            it { expect(dependencies).to eq({}) }
            it { expect(unoptimized_dependencies).to eq(oki: {}) }
            it { expect(schema).to eq s_primitive(34) }
        end

        context 'when visiting parent from pin' do
            template {
                nav(:a).pin { |p1|
                    object(x: _, y: p1.parent.pin { |p2| p2.nav(:a, :b) })
                }
            }

            let(:object) { { a: { x: 12, b: 42 } } }

            it { expect(json).to eq('x' => 12, 'y' => 42) }
            it { expect(dependencies).to eq(a: { x: {}, b: {} }) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:x, s_anything),
                        s_property(:y, s_anything)
                    )
                )
            }
        end

        context 'goto pin followed by constant' do
            template { pin(:lol) { |lol| lol.nav(:x).static(1) } }

            it { expect(dependencies).to eq({}) }
            it { expect(json).to eq 1 }
        end

        context 'when pinning is misused (out of context)' do
            template {
                pinref = nil
                object(
                    a: pin { |p| pinref = p },
                    b: pinref.nav(:lol)
                )
            }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'when pinning is mixed with a "with" context' do
            template {
                pin { |root|
                    with(:a) { |a| a }.object(
                        x: _,
                        y: root.nav(:lol)
                    )
                }
            }

            let(:object) { { a: { x: 34 }, lol: 1 } }

            it { expect(json).to eq('x' => 34, 'y' => 1) }
            it { expect(dependencies).to eq(a: {}, lol: {}) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:x, s_anything),
                        s_property(:y, s_anything)
                    )
                )
            }
        end

        context 'navigating pinning' do
            template {
                pin(:timezone) { |timezone| object(applicant: _.object(:id, tz: timezone)) }
            }

            let(:object) { { applicant: { id: 1 }, timezone: 'LA' } }

            it { expect(json).to eq('applicant' => { 'id' => 1, 'tz' => 'LA' }) }
            it { expect(dependencies).to eq(timezone: {}, applicant: { id: {} }) }
            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:applicant,
                            s_object(
                                s_property(:id, s_anything),
                                s_property(:tz, s_anything)
                            ))
                    )
                )
            }
        end

        context 'pin used twice in same chain' do
            template {
                nav(:a).pin { |a|
                    object(
                        h: nav(:h),
                        a: a.object(
                            x: _,
                            y: a.nav(:lol).parent.nav(:mdr)
                        )
                    )
                }
            }

            let(:object) { { a: { h: 42, x: 13, lol: 11, mdr: 34 } } }

            it { expect(json).to eq('h' => 42, 'a' => { 'x' => 13, 'y' => 34 }) }
            it { expect(dependencies).to eq(a: { h: {}, x: {}, mdr: {} }) }

            it {
                expect(schema).to eq(
                    s_object(
                        s_property(
                            :a,
                            s_object(
                                s_property(:x, s_anything),
                                s_property(:y, s_anything)
                            )
                        ),
                        s_property(:h, s_anything)
                    )
                )
            }
        end

        context 'nested pinning' do
            template {
                pin { |root|
                    nav(:a).pin { |a|
                        object(
                            a: a.nav(:x),
                            root: root.nav(:y)
                        )
                    }
                }
            }

            let(:object) { { a: { x: 42 }, y: 13 } }

            it { expect(json).to eq('a' => 42, 'root' => 13) }

            it {
                expect(schema).to eq(
                    s_object(
                        s_property(:a, s_anything),
                        s_property(:root, s_anything)
                    )
                )
            }
        end
    end
end
