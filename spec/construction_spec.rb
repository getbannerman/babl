require 'babl'

describe ::Babl::Template do
    let(:dsl) { ::Babl::Template.new }
    let(:compiled) { template.compile }
    let(:json) { Oj.load(compiled.json(object)) }
    let(:dependencies) { compiled.dependencies }
    let(:documentation) { compiled.documentation }

    describe '#object' do
        let(:template) { dsl.source { object(:a, :b, c: _, d: nav(:d)) } }
        let(:object) { { a: 1, b: 2, c: 3, d: 4 } }

        it { expect(json).to eq('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4) }
        it { expect(documentation).to eq(a: :__value__, b: :__value__, c: :__value__, d: :__value__) }
        it { expect(dependencies).to eq(a: {}, b: {}, c: {}, d: {}) }

        context 'misused (chaining after object)' do
            let(:template) { dsl.source { object(:a).object(:b) } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end
    end

    describe '#each' do
        context 'when everything is fine' do
            let(:template) { dsl.source { each.nav(:a) } }
            let(:object) { [{ a: 3 }, { a: 2 }, { a: 1 }] }

            it { expect(json).to eq [3, 2, 1] }
            it { expect(dependencies).to eq(__each__: { a: {} }) }
            it { expect(documentation).to eq [:__value__] }
        end

        context 'error while navigating' do
            let(:object) { { box: [{ trololol: 2 }, 42] } }
            let(:template) { dsl.source { nav(:box).each.nav(:trololol) } }

            it { expect { json }.to raise_error(/\__root__\.box\.1\.trololol/) }
        end
    end

    describe '#static' do
        let(:template) { dsl.source { static('1': 'cava') } }
        let(:object) { nil }

        it { expect(json).to eq('1' => 'cava') }
        it { expect(dependencies).to eq({}) }
        it { expect(documentation).to eq('1': 'cava') }

        context 'invalid' do
            let(:template) { dsl.source { static(test: Object.new) } }
            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end
    end

    describe '#array' do
        let(:template) { dsl.source { array('coucou', 45, a: 1, b: [_]) } }
        let(:object) { { b: 12 } }
        it { expect(json).to eq ['coucou', 45, { 'a' => 1, 'b' => [12] }] }
        it { expect(dependencies).to eq(b: {}) }
        it { expect(documentation).to eq ['coucou', 45, a: 1, b: [:__value__]] }
    end

    describe '#call' do
        let(:object) { nil }

        context 'false' do
            let(:template) { dsl.call(false) }

            it { expect(json).to eq false }
            it { expect(dependencies).to eq({}) }
            it { expect(documentation).to eq false }
        end

        context 'block' do
            let(:object) { 2 }
            let(:template) { dsl.call { self * 2 } }

            it { expect(json).to eq 4 }
        end

        context 'hash' do
            let(:object) { nil }
            let(:template) { dsl.call('a' => 1, b: 2) }

            it { expect(json).to eq('a' => 1, 'b' => 2) }
            it { expect(dependencies).to eq({}) }
        end

        context 'array' do
            let(:object) { { b: 42 } }
            let(:template) { dsl.call(['a', 2, :b]) }

            it { expect(json).to eq(['a', 2, 42]) }
            it { expect(dependencies).to eq(b: {}) }
        end

        context 'block' do
            let(:object) { OpenStruct.new(lol: 'tam') }
            let(:template) { dsl.call(:lol) }

            it { expect(json).to eq 'tam' }
            it { expect(dependencies).to eq(lol: {}) }
        end

        context 'template' do
            let(:object) { OpenStruct.new(a: OpenStruct.new(b: 1)) }
            let(:template) { dsl.source { object(coucou: nav(:a).call(nav(:b))) } }

            it { expect(dependencies).to eq(a: { b: {} }) }
            it { expect(json).to eq('coucou' => 1) }
            it { expect(documentation).to eq(coucou: :__value__) }
        end
    end

    describe '#switch' do
        context do
            let(:template) {
                dsl.source {
                    even = nullable.nav(:even?)
                    odd = nullable.nav(:odd?)

                    each.switch(
                        even => nav { |x| "#{x} is even" },
                        odd => nav { |x| "#{x} is odd" },
                        default => continue
                    ).static('WTF')
                }
            }

            let(:object) { [1, 2, nil, 5] }

            it { expect(json).to eq ['1 is odd', '2 is even', 'WTF', '5 is odd'] }
            it { expect(dependencies).to eq(__each__: { even?: {}, odd?: {} }) }
            it {
                expect(documentation).to eq [
                    'Case 1': :__value__,
                    'Case 2': :__value__,
                    'Case 3': 'WTF'
                ]
            }
        end

        context 'static condition' do
            let(:template) { dsl.source { switch(true => 42) } }
            let(:object) { {} }
            it { expect(json).to eq 42 }
        end

        context 'navigation before continue' do
            let(:template) { dsl.source { nav(:abc).switch(false => 1, default => nav(:lol).continue).object(val: nav(:ok)) } }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'continue in sub-object' do
            let(:template) { dsl.source { object(a: switch(default => object(x: continue))) } }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'unhandled default' do
            let(:object) { { abc: { lol: { ok: 42 } } } }
            let(:template) { dsl.source { switch(false => 1) } }

            it { expect(dependencies).to eq({}) }
            it { expect { json }.to raise_error Babl::RenderingError }
        end

        context 'continue without switch' do
            let(:template) { dsl.source { continue } }

            it { expect { compiled }.to raise_error Babl::InvalidTemplateError }
        end

        context 'non serializable objects are allowed internally' do
            let(:template) { dsl.source { switch(test: 42) } }
            let(:object) { { test: Object.new } }

            it { expect(json).to eq 42 }
        end

        context do
            let(:template) {
                dsl.source {
                    nav(:test).switch(nav(:keke) => parent.nav(:lol))
                }
            }
            it { expect(dependencies).to eq(test: { keke: {} }, lol: {}) }
        end
    end

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

    describe '#merge' do
        context do
            let(:template) {
                dsl.source {
                    merge(
                        object(a: static('A')),
                        b: _
                    )
                }
            }

            let(:object) { { b: 42 } }

            it { expect(json).to eq('a' => 'A', 'b' => 42) }
            it { expect(dependencies).to eq(b: {}) }
            it { expect(documentation).to eq('Merge 1': { a: 'A' }, 'Merge 2': { b: :__value__ }) }
        end

        context 'merge inside object' do
            let(:template) { dsl.source { object(toto: merge(_, lol: 42)) } }
            let(:object) { { toto: { cool: 'ouai' } } }

            it { expect(json).to eq('toto' => { 'lol' => 42, 'cool' => 'ouai' }) }
        end
    end
end
