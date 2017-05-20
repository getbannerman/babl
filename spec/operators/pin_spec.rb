require 'spec_helper'

describe ::Babl::Operators::Pin do
    include SpecHelper::Operators

    describe '#pin' do
        context 'simple pinning' do
            let(:template) {
                dsl.source {
                    nav(:a).pin { |a|
                        nav(:b).object(
                            x: _,
                            y: a.nav(:y)
                        )
                    }
                }
            }

            let(:object) {
                { a: { b: { x: 42 }, y: 13 } }
            }

            it { expect(json).to eq('x' => 42, 'y' => 13) }
            it { expect(dependencies).to eq(a: { y: {}, b: { x: {} } }) }
            it { expect(documentation).to eq(x: :__value__, y: :__value__) }
        end

        context 'when visiting parent from pin' do
            let(:template) {
                dsl.source {
                    nav(:a).pin { |p1|
                        object(x: _, y: p1.parent.pin { |p2| p2.nav(:a, :b) })
                    }
                }
            }

            let(:object) { { a: { x: 12, b: 42 } } }

            it { expect(json).to eq('x' => 12, 'y' => 42) }
            it { expect(dependencies).to eq(a: { x: {}, b: {} }) }
            it { expect(documentation).to eq(x: :__value__, y: :__value__) }
        end

        context 'when pinning is misused (out of context)' do
            let(:template) {
                dsl.source {
                    pinref = nil
                    object(
                        a: pin { |p| pinref = p },
                        b: pinref.nav(:lol)
                    )
                }
            }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'when pinning is mixed with a "with" context' do
            let(:template) {
                dsl.source {
                    pin { |root|
                        with(:a) { |a| a }.object(
                            x: _,
                            y: root.nav(:lol)
                        )
                    }
                }
            }

            let(:object) { { a: { x: 34 }, lol: 1 } }

            it { expect(json).to eq('x' => 34, 'y' => 1) }
            it { expect(dependencies).to eq(a: {}, lol: {}) }
            it { expect(documentation).to eq(x: :__value__, y: :__value__) }
        end

        context 'navigating pinning' do
            let(:template) {
                dsl.source {
                    pin(:timezone) { |timezone| object(applicant: _.object(:id, tz: timezone)) }
                }
            }

            let(:object) { { applicant: { id: 1 }, timezone: 'LA' } }

            it { expect(json).to eq('applicant' => { 'id' => 1, 'tz' => 'LA' }) }
            it { expect(dependencies).to eq(timezone: {}, applicant: { id: {} }) }
            it { expect(documentation).to eq(applicant: { id: :__value__, tz: :__value__ }) }
        end

        context 'pin used twice in same chain' do
            let(:template) {
                dsl.source {
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
            }

            let(:object) { { a: { h: 42, x: 13, lol: 11, mdr: 34 } } }

            it { expect(json).to eq('h' => 42, 'a' => { 'x' => 13, 'y' => 34 }) }
            it { expect(dependencies).to eq(a: { h: {}, x: {}, lol: {}, mdr: {} }) }
            it { expect(documentation).to eq(h: :__value__, a: { x: :__value__, y: :__value__ }) }
        end

        context 'nested pinning' do
            let(:template) {
                dsl.source {
                    pin { |root|
                        nav(:a).pin { |a|
                            object(
                                a: a.nav(:x),
                                root: root.nav(:y)
                            )
                        }
                    }
                }
            }

            let(:object) { { a: { x: 42 }, y: 13 } }

            it { expect(json).to eq('a' => 42, 'root' => 13) }
            it { expect(documentation).to eq(a: :__value__, root: :__value__) }
        end
    end
end
