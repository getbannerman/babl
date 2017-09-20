![BABL Logo](https://github.com/getbannerman/babl/raw/master/logo-babl.png)

[![Build Status](https://travis-ci.org/getbannerman/babl.svg?branch=master)](https://travis-ci.org/getbannerman/babl)
[![Coverage Status](https://coveralls.io/repos/github/getbannerman/babl/badge.svg)](https://coveralls.io/github/getbannerman/babl)
[![Gem](https://img.shields.io/gem/v/babl-json.svg)](https://rubygems.org/gems/babl-json)
[![Downloads](https://img.shields.io/gem/dt/babl-json.svg)](https://rubygems.org/gems/babl-json)

BABL (Bannerman API Builder Language) is a functional Ruby DSL for generating JSON in APIs.

It plays a role similar to [RABL](https://github.com/nesquena/rabl), [JBuilder](https://github.com/rails/jbuilder), [Grape Entity](https://github.com/ruby-grape/grape-entity), [AMS](https://github.com/rails-api/active_model_serializers), and many others.

# Example

```
gem install babl-json
```

```ruby
require 'babl'
require 'date'

Author = Struct.new(:name, :birthyear)
Article = Struct.new(:author, :title, :body, :date, :comments)
Comment = Struct.new(:author, :date, :body)

# Let's define some data
data = [
    Article.new(
        Author.new("Fred", 1990),
        'Introducing BABL',
        'Blablabla',
        DateTime.now,
        [
            Comment.new(
                Author.new("Luke", 1991),
                DateTime.now,
                'Great gem'
            )
        ]
    )
]

# Define a template
template = Babl.source {

    # A template is a first class object, it can be stored in a variable ("inline partial")
    # and re-used later.

    # This template can serialize an Author for instance into an object.
    author = object(
        name: _,
        birthyear: _
    )

    # Produce a JSON object
    object(

        # Visit each article of from collection and produce a JSON object for each elements
        articles: each.object(

            # nav(:iso8601) can be seen as method
            date: _.nav(:iso8601),

            # '_' is a synonym of 'nav(:title)'
            title: _,
            body: _,

            # You can chain another template using call()
            author: _.(author),

            # Visit each comment, and produce a JSON object for each of them.
            comments: _.each.object(

                author: _.(author),

                # Type assertions can be (optionally) specified.
                # - They add runtime type checks
                # - They are added to JSON-Schema
                body: _.string,
                date: _.nav(:iso8601).string
            )
        )
    )
}

# All the magic happens here: the template is transformed into a fast serializer.
compiled_template = template.compile

# Serialize some data into JSON
compiled_template.json(data)

# =>
# {
#     "articles":[
#       {
#         "date":"2017-09-07T08:42:42+02:00",
#         "title":"Introducing BABL",
#         "body":"Blablabla",
#         "author":{
#           "name":"Fred",
#           "birthyear":1990
#         },
#         "comments":[
#           {
#             "author":{
#               "name":"Luke",
#               "birthyear":1991
#             },
#             "body":"Great gem",
#             "date":"2017-09-07T08:42:42+02:00"
#           }
#         ]
#       }
#     ]
#   }

# render() is like json(), but produces a Hash instead of a JSON
compiled_template.render(data)

# Output a JSON-Schema description of the template
compiled_template.json_schema
```

# Benchmark

```
                                     user     system      total        real
RABL                             3.180000   0.010000   3.190000 (  3.189780)
JBuilder                         0.700000   0.000000   0.700000 (  0.708928)
BABL                             0.540000   0.000000   0.540000 (  0.540724)
BABL (compiled once)             0.410000   0.010000   0.420000 (  0.412431)
Handwritten Ruby                 0.080000   0.000000   0.080000 (  0.081407)
```

Results using [code generation [WIP]](https://github.com/getbannerman/babl/pull/21):
```
                                     user     system      total        real
BABL (compiled once + codegen)   0.170000   0.000000   0.170000 (  0.168479)
```
See [source code](spec/perfs/comparison_spec.rb).

# Features

## Template compilation

A BABL template has to be compiled before it can be used. This approach carries several advantages:
- Many errors can be detected earlier during the development process.
- Partials are resolved only once, during compilation: zero overhead at render time.
- Template fragments which are provably constant are pre-rendered at compilation time.
- [Code generation [WIP]](https://github.com/getbannerman/babl/pull/21) should bring performances close to handcrafted Ruby code.

## Automatic documentation (JSON schema)

BABL can automatically document a template by generating a JSON-Schema. Combined with optional [type-checking assertions](pages/operators.md#typed), it becomes possible to do some exciting things.

For instance, it is possible to generate TypeScript interfaces by feeding the exported JSON-Schema to https://github.com/bcherny/json-schema-to-typescript.

See [how to generate a JSON-Schema](pages/templates.md#json_schema).

## Dependency analysis (automatic preloading)

Due to the static nature of BABL templates, it is possible to determine in advance which methods will be called on models objects during rendering. This is called dependency analysis. In practice, the extracted dependencies can be passed to a preloader, in order to avoid all N+1 issues.

Please note that this requires a compatible preloader implementation. At Bannerman, we are using **Preeloo**. It natively supports ActiveRecord associations, computed columns, and custom preloadable properties. Unfortunately, it hasn't been released publicly (yet), because it still has bugs and limitations.

# Resources

- [Understanding BABL: fundamental concepts](pages/concepts.md)
- [Getting started (with Rails)](pages/getting_started.md)
- [Playing with templates (without Rails)](pages/templates.md)
- [List of all operators](pages/operators.md)
- [Limitations](pages/limitations.md)
- [Design rationale](pages/rationale.md)
- [Changelog](CHANGELOG.md)

# License

Copyright (c) 2017 [Bannerman](https://www.bannerman.com/), [Frederic Terrazzoni](https://github.com/fterrazzoni)

Licensed under the [MIT license](https://opensource.org/licenses/MIT).
