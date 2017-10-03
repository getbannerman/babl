# frozen_string_literal: true
require 'spec_helper'

describe Babl::Operators::Switch do
    extend SpecHelper::OperatorTesting
    let(:object) { [1, 2, 3] }

    describe '#concat' do
        context 'fixed + fixed' do
            template { concat(dep(:a).array(1), [2, 3], dep(:b).array(4)) }

            it { expect(json).to eq [1, 2, 3, 4] }
            it { expect(dependencies).to eq(a: {}, b: {}) }

            it {
                expect(schema).to eq s_fixed_array(
                    s_primitive(1),
                    s_primitive(2),
                    s_primitive(3),
                    s_primitive(4)
                )
            }
        end

        context 'dyn + fixed + dyn' do
            template { concat(each.static(3), [1], each.static(2)) }

            it {
                expect(schema).to eq s_dyn_array(
                    s_any_of(
                        s_primitive(1),
                        s_primitive(2),
                        s_primitive(3)
                    )
                )
            }

            it { expect(json).to eq [3, 3, 3, 1, 2, 2, 2] }
        end

        context 'dyn of numbers + dyn of integer + fixed' do
            template { concat(each.number, each.integer, [5]) }

            it { expect(schema).to eq s_dyn_array(s_number) }
            it { expect(json).to eq [1, 2, 3, 1, 2, 3, 5] }
        end

        context 'null + fixed' do
            template { concat(null, []) }

            it { expect(schema).to eq s_fixed_array }
            it { expect(json).to eq [] }
        end

        context 'null' do
            template { concat(nil) }

            it { expect(schema).to eq s_fixed_array }
            it { expect(json).to eq [] }
        end

        context 'not an array at runtime' do
            template { concat(itself) }

            let(:object) { { a: 1 } }

            it { expect { compiled }.not_to raise_error }
            it { expect { json }.to raise_error Babl::Errors::RenderingError }
        end

        context 'concat nothing' do
            template { concat }

            it { expect(json).to eq [] }
            it { expect(schema).to eq s_fixed_array }
        end

        context 'not an array at compile time' do
            template { concat(object(a: 1)) }

            it { expect { compiled }.to raise_error Babl::Errors::InvalidTemplate }
        end

        context 'anything + fixed' do
            template { concat(itself, [1]) }

            it { expect(schema).to eq s_dyn_array(s_anything) }
            it { expect(json).to eq [1, 2, 3, 1] }
        end

        context 'array + nullable array' do
            template { concat(nullable.array(3), [1, 2]) }

            let(:object) { nil }

            it {
                expect(schema).to eq s_dyn_array(
                    s_any_of(
                        s_primitive(1),
                        s_primitive(2),
                        s_primitive(3)
                    )
                )
            }

            it { expect(json).to eq [1, 2] }
        end

        context 'complex optimizable concat' do
            template {
                concat(
                    array(itself),
                    [1, 2],
                    array(itself, 3)
                )
            }

            it { expect(json).to eq [[1, 2, 3], 1, 2, [1, 2, 3], 3] }
        end

        context 'nullable + nullable + nullable' do
            template {
                concat(
                    nullable.array,
                    nullable.array(1),
                    nullable.array(2)
                )
            }

            it { expect(json).to eq [1, 2] }
            it { expect(schema).to eq s_dyn_array(s_any_of(s_primitive(1), s_primitive(2))) }
        end

        context 'fully constant' do
            template { concat(array(1, 2), [], nil, [5]) }

            it { expect(json).to eq [1, 2, 5] }
            it { expect(compiled.render(nil)).to equal(compiled.render(nil)) }
        end
    end
end
