# frozen_string_literal: true
require 'spec_helper'
require 'benchmark'
require 'jbuilder'
require 'multi_json'

describe 'JBuilder comparison' do
    extend SpecHelper::OperatorTesting

    let(:person_class) { Babl::Utils::Value.new(:name, :birthyear, :job, :url) }
    let(:article_class) { Babl::Utils::Value.new(:author, :title, :body, :date, :references, :comments) }
    let(:comment_class) { Babl::Utils::Value.new(:author, :date, :email, :body) }
    let(:reference_class) { Babl::Utils::Value.new(:name, :url) }

    let(:data) {
        Array.new(100) {
            author = person_class.new("Fred", 1990, "Software developer", "https://github.com/fterrazzoni")
            references = [
                reference_class.new('BABL repo', 'https://github.com/getbannerman/babl/'),
                reference_class.new('JBuilder repo', 'https://github.com/rails/jbuilder')
            ]
            comments = [
                comment_class.new(author, Time.now, 'frederic.terrazzoni@gmail.com', 'I like it')
            ]
            article_class.new(author, 'Profiling Jbuilder', 'This is a very short explanation', Time.now, references, comments)
        }
    }

    let(:jbuilder_test) {
        -> {
            Jbuilder.encode do |json|
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
        }
    }

    let(:babl_template) {
        Babl::Template.new.source {
            author = object(:name, :birthyear, :job)

            each.object(
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

    let(:babl_test) {
        -> { babl_template.compile(pretty: false).json(data) }
    }

    let(:precompiled_babl_test) {
        compiled = babl_template.compile(pretty: false)
        -> { compiled.json(data) }
    }

    let(:n) { 50 }

    before { data }

    it {
        expect([
            MultiJson.load(jbuilder_test.call),
            MultiJson.load(babl_test.call),
            MultiJson.load(precompiled_babl_test.call)
        ].uniq.size).to eq 1
    }

    it {
        Benchmark.bm do |x|
            x.report("Jbuilder") { n.times { jbuilder_test.call } }
            x.report("BABL") { n.times { babl_test.call } }
            x.report("Precompiled BABL") { n.times { precompiled_babl_test.call } }
        end
    }
end
