# BABL #

[![Build Status](https://travis-ci.org/getbannerman/babl.svg?branch=master)](https://travis-ci.org/getbannerman/babl)

BABL (Bannerman API Builder Language) is a templating langage for generating JSON in APIs.

It plays a role similar to [RABL](https://github.com/nesquena/rabl), [JBuilder](https://github.com/rails/jbuilder), [Grape Entity](https://github.com/ruby-grape/grape-entity), [AMS](https://github.com/rails-api/active_model_serializers), and many others. However, unlike existing tools, BABL has several advantages.


### Static compilation

BABL is a simple Ruby DSL. Unlike RABL, the template code is fully parsed and executed before any data is available. This approach makes it possible to detect errors earlier and document the output schema automatically, without data. Experimentally, it also makes partials evaluation much faster, because partials are loaded only once.

### Automatic preloading

BABL is also able to infer the "input schema". It can loosely be seen as the list of properties we need to read from the models to construct the JSON output. These *dependencies* can be used to retrieve data more efficiently. For instance, all ActiveRecord associations can be preloaded automatically using this mechanism.

### Simple syntax

JSON is simple, and generating JSON should be as simple as possible.

BABL template:

```ruby
object(
    document: object(
        :id, :title

        owner: _.nullable.object(:id, :name),
        authors: _.each.object(:id, :name),
        category: 'Not implemented'
    )
)
```

Output:

```json
{
    "document": {
        "id": 1,
        "title": "Hello BABL",
        "owner": null,
        "authors": [
            { "id": 4, "name": "Fred" },
            { "id": 5, "name": "Vivien" }
        ],
        "category": "not implemented"
    }
}
```

Interestingly, this JSON output is also a valid BABL template. This property makes it very easy to mix static JSON and dynamic content during developpement.

## Documentation

Not yet available.

## Current limitations

### Automatic preloading

This feature only works if BABL is configured to use an external preloader.

As of today, the only compatible preloader implementation *has not been released* yet, because it has severe limitations. Hopefully, it will be available soon :-)

### Automatic documentation

The structure of the JSON produced by a BABL template can be documented using [JSON-Schema](http://json-schema.org/).

### Rails integration

This gem implements support of `*.babl` views in [Rails](https://github.com/rails/rails/).

In theory, the template could be compliled once for all and re-used for subsequent requests. In practice, today's implementation will re-compile the template at every request, because Rails templating mechanism doesn't make our life easy.

If it turns out to be a performance bottleneck, we will try to work around this issue.

### Recursion

BABL does not support recursive templates. The first reason is that it makes dependency tracking more complicated (especially on preloader side). The other reason is that it is not as useful as it might seem.

## License

Copyright (c) 2017 [Bannerman](https://www.bannerman.com/), [Frederic Terrazzoni](https://github.com/fterrazzoni)

Licensed under the [MIT license](https://opensource.org/licenses/MIT).