require 'spec_helper'

describe Babl::Operators::With do
    extend SpecHelper::OperatorTesting

    describe '#with' do
        context 'everything is fine' do
            template {
                object(
                    result: with(
                        unscoped,
                        :msg,
                        _.parent.nav(:msg).dep(:lol)
                    ) { |obj, a, b| "#{a} #{b} #{obj[:msg]}" }
                )
            }

            let(:object) { { result: 42, msg: 'Hello C' } }

            it { expect(json).to eq('result' => 'Hello C Hello C Hello C') }
            it { expect(dependencies).to eq(result: {}, msg: { lol: {} }) }
            it { expect(schema).to eq s_object(s_property(:result, s_anything)) }
        end

        context 'when the block raise an exception' do
            template { with { raise 'lol' } }

            it { expect { json }.to raise_error(/\__root__\.__block__/) }
        end
    end
end
