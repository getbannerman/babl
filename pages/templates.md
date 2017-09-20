# Playing with templates

## Setup

```ruby
gem install babl-json
```
and
```ruby
require 'babl'
```

## Creating a template

A BABL template needs to be compiled before it can be used. This is done automatically if BABL is configured with Rails, but it can also be done manually.

```ruby
# Create a template which is displaying a document's authors
template = Babl.source {
    object(
        author_names: nav(:authors).each.nav(:name).string
    )
}

# The template needs to be compiled before it can be used
compiled_template = template.compile
```

## <a name="rendering"></a>Rendering

```ruby
# Create some data
document = {
    content: 'foo',
    authors: [
        { id: 1, name: 'Fred' },
        { id: 3, name: 'Vivien' }
    ]
}

data = compiled_template.render(document)
# data = { author_names: ['Fred', 'Vivien'] }

json = compiled_template.json(document)
# json = "{ "author_names": [\"Fred\", \"Vivien\"] }"
```

BABL always performs checks to ensure that the data are serializable. The only serializable classes are:
- `NilClass`
- `TrueClass`
- `FalseClass`
- `String`
- `Symbol`
- `Numeric`
- `Hash`
- `Array`

## <a name="json_schema"></a>JSON-Schema

BABL internally maintains a representation of the output schema and exports it as a JSON-Schema. It can well serve documentation purposes, but it can also be useful if JSON-Schema is used as an intermediary to produce type definitions in another language.

For instance, at Bannerman, we are generating TypeScript interfaces from BABL templates using this NPM package [json-schema-to-typescript](https://github.com/bcherny/json-schema-to-typescript).

```ruby
schema = compiled_template.json_schema
```

```js
{
    "type":"object",
    "properties":{
        "author_names":{
            "type":"array",
            "items":{
                "type":"string"
            }
        }
    },
    "additionalProperties":false,
    "required":[
        "author_names"
    ]
}
```

## Composition

A template can be referenced directly from inside another template. In fact, this is exactly what happens when [partials](operators.md#partial) are used.

```ruby
user = Babl.source {
    object(name: _)
}

article = Babl.source {
    object(
        author: _.(user),
        reviewers: _.each.(user)
    )
}
```

## <a name="dependencies"></a>Dependencies

Every time [`#nav`](operators.md#nav) or [`#each`](operators.md#each) is called, BABL adds the property at the current position in the dependency tree. Additionally, dependencies can be manually declared using `#dep`.

```ruby
dependencies = compiled_template.dependencies
# dependencies = { authors: { __each__: { name: {} } } }
```

### Dependency tracking

Dependency tracking stops as soon as a block-based navigation is encountered in the chain. For instance, the template `nav(:a).nav(:b).nav { |x| x }.nav(:c)` has the following dependencies: `{ a: { b: {} } }`.

## <a name="user_defined"></a>User-defined operators

Adding a new operator is as simple as adding a new method to `BABL::Template`.

- If can be done via subclassing: `class MyTemplate < BABL::Template; ... end`.
- Or by including a module in `BABL::Template`.

### Example

Define a new operator `#iso8601`:
```ruby
    module BablExt
        def iso8601
            source {
                nav { |date| date.iso8601 }.string
            }
        end
    end

    Babl::Template.include(BablExt)
```

Use it in a template:
```ruby
{
    mission: {
        starts_at: _.iso8601,
        ends_at: _.iso8601,
        canceled_at: _.nullable.iso8601
    }
}
```

