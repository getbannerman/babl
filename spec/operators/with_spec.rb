require 'spec_helper'

describe ::Babl::Operators::With do
    include SpecHelper::Operators

    describe '#with' do
        context 'everything is fine' do
            let(:template) {
                dsl.source {
                    object(
                        result: with(
                            unscoped,
                            :msg,
                            _.parent.nav(:msg).dep(:lol)
                        ) { |obj, a, b| "#{a} #{b} #{obj[:msg]}" }
                    )
                }
            }

            let(:object) { { result: 42, msg: 'Hello C' } }

            it { expect(json).to eq('result' => 'Hello C Hello C Hello C') }
            it { expect(dependencies).to eq(result: {}, msg: { lol: {} }) }
            it { expect(documentation).to eq(result: :__value__) }
        end

        context 'when the block raise an exception' do
            let(:object) { nil }
            let(:template) { dsl.source { with { raise 'lol' } } }
            it { expect { json }.to raise_error(/\__root__\.__block__/) }
        end
    end
end
