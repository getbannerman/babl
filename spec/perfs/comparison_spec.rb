# frozen_string_literal: true
require 'spec_helper'
require 'benchmark'
require 'jbuilder'
require 'multi_json'
require 'rabl'

describe 'JBuilder comparison' do
    extend SpecHelper::OperatorTesting

    before {
        stub_const('Author', Babl::Utils::Value.new(:name, :birthyear, :job, :url))
        stub_const('Article', Babl::Utils::Value.new(:author, :title, :body, :date, :references, :comments))
        stub_const('Comment', Babl::Utils::Value.new(:author, :date, :email, :body))
        stub_const('Reference', Babl::Utils::Value.new(:name, :url))
    }

    let(:data) {
        Array.new(100) {
            author = Author.new("Fred", 1990, "Software developer", "https://github.com/fterrazzoni")
            references = [
                Reference.new('BABL repo', 'https://github.com/getbannerman/babl/'),
                Reference.new('JBuilder repo', 'https://github.com/rails/jbuilder')
            ]
            comments = [
                Comment.new(author, Time.now, 'frederic.terrazzoni@gmail.com', 'I like it')
            ]
            Article.new(author, 'Profiling Jbuilder', 'This is a very short explanation', Time.now, references, comments)
        }
    }

    let(:jbuilder_test) {
        -> {
            Jbuilder.new do |json|
                json.articles do
                    json.array! data do |article|
                        json.author(article.author, :name, :birthyear, :job)
                        json.title article.title
                        json.body article.body
                        json.date article.date.iso8601
                        json.references article.references do |reference|
                            json.name reference.name
                            json.url reference.url
                        end
                        json.comments article.comments do |comment|
                            json.author(comment.author, :name, :birthyear, :job)
                            json.email comment.email
                            json.body comment.body
                            json.date comment.date.iso8601
                        end
                    end
                end
            end.attributes!
        }
    }

    let(:rabl_test) {
        Rabl.configuration.include_child_root = false

        code = '
            collection self, root: :articles, object_root: false

            attributes :title, :body
            node(:date) { |article| article.date.iso8601 }

            child :author do
                attributes :name, :birthyear, :job
            end

            child :references do
                attributes :name, :url
            end

            child :comments do
                attributes :email, :body
                node(:date) { |article| article.date.iso8601 }

                child :author do
                    attributes :name, :birthyear, :job
                end
            end
        '

        template = Rabl::Engine.new(code)
        -> { template.apply(data, {}).to_dumpable }
    }

    let(:babl_template) {
        Babl::Template.new.source {
            author = object(:name, :birthyear, :job)

            {
                articles: each.object(
                    title: _,
                    body: _,
                    author: _.(author),
                    date: _.nav(&:iso8601),
                    references: _.each.object(:name, :url),
                    comments: _.each.object(
                        author: _.(author),
                        email: _,
                        body: _,
                        date: _.nav(:iso8601)
                    )
                )
            }
        }
    }

    let(:babl_test) {
        -> { babl_template.compile(pretty: false).render(data) }
    }

    let(:precompiled_babl_test) {
        compiled = babl_template.compile(pretty: false)
        -> { compiled.render(data) }
    }

    let(:benchmarks) {
        {
            'RABL' => rabl_test,
            'JBuilder' => jbuilder_test,
            'BABL' => babl_test,
            'BABL (compiled once)' => precompiled_babl_test
        }
    }

    let(:n) { 50 }

    # Ensure all benchmarks are producing the same JSON
    before { expect(benchmarks.values.map(&:call).map { |x| MultiJson.load(MultiJson.dump(x)) }.uniq.size).to eq 1 }

    # Run benchmarks
    it {
        Benchmark.bm(30) do |x|
            benchmarks.each do |description, benchmark|
                x.report(description) { n.times { benchmark.call } }
            end
        end
    }
end
