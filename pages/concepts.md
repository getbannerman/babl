# Concepts

BABL is a declarative langage designed for expressing simple transformations from models (PORO, ActiveRecord, ...) to JSON, by combining navigation & construction operators.

## Navigation

In a real world project, model objects are typically related to many others. This is especially true for ActiveRecords, which are often linked together via associations. By the mean of **navigation operators**, BABL can explore the object graph in order to fetch the data it needs.

At template's root, the **current object** is set to the model you want to serialize. It changes after a navigation operator is used (such as `#nav`, `#with`, ...). Multiple navigation operators can be chained.

In BABL world, *navigating* is almost always a synonym for *calling a method* ([except for `Hash`](operators.md#nav)).

Example template (`self` is written explicitly for demonstration purpose):
```ruby
    self.nav(:document).nav(:author)
```

- `self`: The **current object** is the model to serialize
- `self.nav(:document)`: Navigate to `document` and update the **current object** for the rest of the chain.
- `self.nav(:document).nav(:author)`: Navigate again to `author` starting from the **current object** (which was pointing on the document).
- Et cætera...

Semantically, this BABL template is ~ equivalent to this Ruby code:
```ruby
model.document.author
```

## Construction

Construction operators are necessary to produce JSON. They do not affect the **current object**, but they always terminate the chaining.

Additionally, when a chain is not terminated by a construction operator, the **current object** is implicitly dumped into the JSON output at the current position. For instance, the (minimal) template `self` will dump the input model without any transformation, assuming it is serializable.

The most useful construction operator is [`#object`](operators.md#object): it constructs a JSON object.

Example:
```ruby
object(
    document: nav(:document).object(
        id: nav(:id),
        content: nav(:content),
        author: nav(:author).object(
            id: nav(:id),
            name: nav(:name)
        )
    )
)
```

Semantically, this BABL template is ~ equivalent to this Ruby code:
```ruby
    {
        document: {
            id: model.document.id,
            content: model.document.content,
            author: {
                id: model.document.author.id,
                name: model.document.author.name
            }
        }
    }
```

### Side node: few words about `_` (`enter`)

The pattern `object(xxx: nav(:xxx))` tends to appear a lot if the keys are named after the properties on the model. To alleviate this, there is a macro `_`. See [`#enter`](operators.md#enter) for more details.

```ruby
object(
    document: _.object(
        id: _,
        content: _,
        author: _.object(
            id: _,
            name: _
        )
    )
)
```

## Templates

Like most Ruby DSLs, a BABL template is just Ruby code executed in a special context (where Ruby's `self` is a `Babl::Template` instance).
The last statement of a BABL template is expected to return another `Babl::Template`, or any value that can be interpreted as a template. See implicit forms in [Operators](operators.md) for more details.

It is important to know that an instance of `Babl::Template`:
- Is an immutable object.
- Doesn't depend on the context it is defined in.
- Can be re-used in different contexts.

```ruby
# This inline template is defined at top-level, but properties will
# be fetched starting from 'checkin' and 'checkout', depending on
# where it is used.
checkinout = _.nullable.object(
    id: _,
    time: _
)

object(
    mission: object(
        id: _,
        starts_at: _,
        ends_at: _,
        # Re-using 'checkinout' structure twice is okay
        # Each one will have a different replacement for '_'
        checkin: checkinout,
        checkout: checkinout
    )
)
```

----

Learn more about [Babl::Template](templates.md).
