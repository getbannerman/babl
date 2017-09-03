# <a name="array"></a>`array(template1, template1, ...)`

Create a fixed-size array whose each element is a template.

## Usage

```ruby
array(
    static(42),
    object(test: static('bar'))
)
```

This template will produce the following JSON data:

```js
 [ 42, { "test": 'bar' } ]
```

## Implicit form

A native Ruby array can also be passed wherever a BABL template is expected. In this case, the operator `#array` is implicitly called. Using all implicit forms, The previous template can be rewritten:

```ruby
[ 42, { test: 'bar' } ]
```

# <a name="call"></a>`call(template)`

Append another BABL template to the current chain. `template` may be an instance of `Babl::Template` or any object which is implicitely interpretable as a template (implicit forms).

## Usage

```ruby
person = object(
    name: nav(:last_name),
    age: _
)

object(
    father: _.call(person),
    mother: _.call(person)
)
```

This is semantically equivalent to this Ruby code:

```ruby
{
    father: {
        name: model.father.last_name,
        age: model.father.age
    },
    mother: {
        name: model.mother.last_name,
        age: model.mother.age
    }
}
```

## Ruby's dot-parentheses notation

It is possible to use the shorter Ruby's dot-parentheses notation to call `call`. The template can then be rewritten:

```ruby
object(
    father: _.(person),
    mother: _.(person)
)
```

# <a name="continue"></a>`continue`

See [`#switch`](#switch).

# <a name="default"></a>`default`

Alias of `static(true)`.

See [`#switch`](#switch).

# <a name="dep"></a>`dep`

Declare a dependency without actually navigating.

# <a name="each"></a>`each`

Produce a JSON array whose elements are taken from the **current object**, which is expected to be `Enumerable`.

Optionally, a template for serializing each individual element can be chained after `#each`.

## Usage

```ruby
object(
    fruits: each.object(
        name: _
    )
)
```

Semantically equivalent Ruby code:

```ruby
{
    fruits: model.map { |fruit|
        {
            name: fruit.name
        }
    }
}
```

# <a name="enter"></a>`_` (alias for `enter`)


A lot of repetitions tend to appear in `object(...)` if the keys are named after the properties on the model. To alleviate this, there is a macro `_` which is replaced by `nav(:xxx)`, where `xxx` is determined from the innermost [`#object`](#object)'s key.

Repetitive template:
```ruby
object(
    xxx: nav(:xxx),
    yyy: nav(:yyy),
    zzz: nav(:zzz)
    # Etc...
)
```

Equivalent template:
```ruby
object(
    xxx: _,
    yyy: _,
    zzz: _
    # Etc...
)
```

# <a name="extends"></a>`extends(file_name, *templates)`

This operator is a shortcut for calling & extending a partial.

All it does is `merge(partial(file_name), *templates)`.

If `*templates` is empty, it boils down to `partial(file_name)`.

## Usage

```ruby
    object(
        user: _.extends(
            'api/users/user_base.babl',
            phone: _,
        )
    )
```

It is equivalent to this expanded template:

```ruby
    object(
        user: nav(:user).merge(
            partial('api/users/user_base.babl'),
            object(phone: nav(:phone)),
        )
    )
```

# <a name="merge"></a>`null?`

Construct a boolean, indicating wether the **current object** is `Nil` or not.

# <a name="merge"></a>`merge`

Construct a JSON object by merging multiple templates together, assuming they were producing JSON objects (`nil` is accepted and ignored).

## Usage

```ruby
merge(
    object(xxx: 1, yyy: 2),
    object(yyy: 3, zzz: 4)
)
```

This is semantically equivalent to this Ruby code:
```ruby
{ xxx: 1, yyy: 2 }.merge({ yyy: 3, zzz: 4 })
```

# <a name="nav"></a>`nav(*properties, &block)`

*Navigate* to a property on the model, and update the **current object**.
**current object**.

*Navigate* is almost always a synonym for *call a method*. There is only one exception for `Hash` instances (navigation is delegated to `Hash#fetch`).

Multiple properties can be passed:

- `nav(:a, :b, &block)` is equivalent to `nav(:a).nav(:b).nav(&block)`.

It is also possible to pass a block:
- `nav(&block)` is equivalent to `with(&block)`. See the operator [`#with`](#with) for more details.

## Usage

```ruby
{
    group_name: nav(:name),
    nb_admins: nav(:users) { count(&:admin?) }
}
```

This is semantically equivalent to this Ruby code:

```ruby
{
    group_name: model.name,
    nb_admins: model.users.count(&:admin?)
}
```

## Implicit form

A `Symbol` is always converted into a navigation operator wherever a BABL template is expected. For instance,
```ruby
object(
    value: :my_value
)
```
is expanded as:
```ruby
object(
    value: nav(:my_value)
)
```

# <a name="null"></a>`null`

Produce a JSON `null`. It is a shortcut for `static(nil)`. BABL also accepts `nil` wherever a BABL template is expected.

This operator has been added in order to make JSON a subset of BABL.

# <a name="nullable"></a>`nullable(condition = null?)`

If the condition is truthy, stop evaluating the chain and emit `null`. Otherwise, continue chain evaluation.

Using the default condition, the chain is stopped if the **current object** is `Nil`.

## Usage

```ruby
nav(:credit_card).nullable.object(last4: _, type: _)
```

This is semantically equivalent to this Ruby code:
```ruby
if model.credit_card.nil?
    nil
else
    {
        last4: model.credit_card.last4,
        type: model.credit_card.type
    }
end
```

## Side note

Interestingly, this operator is entirely implemented using [`#switch`](#switch).

```ruby
def nullable
    source {
        switch(
            nav(&:nil?) => nil,
            default => continue
        )
    }
end
```

# <a name="object"></a>`object(*simple_keys, **key_values)`

Construct a JSON object whose keys are statically known.

### Implicit form

A native Ruby hash `{ ... }` is handled by BABL as if it was `object(...)`.

```ruby
{
    mission: {
        id: _,
        starts_at: _,
        ends_at: _,
    }
}
```

is expanded as:

```ruby
object(
    mission: object(
        id: _,
        starts_at: _,
        ends_at: _,
    )
)
```

# <a name="parent"></a>`parent`

Revert the latest navigation. It is useful when you need to fetch a single property from the previous object.

## Usage

```ruby
object(
    event: object(
        checkin: nav(:checkin).object(
            timestamp: nav(:timestamp),
            timezone: parent.nav(:location).nav(:timezone)
        )
    )
)
```

is semantically equivalent to this Ruby code:

```ruby
{
    event: {
        checkin: {
            time: model.checkin.time,
            timezone: model.location.timezone
        }
    }
}
```

# <a name="partial"></a>`partial(file_name)`

Load a BABL template from a file, and append it to the current chain.

`api/user.babl`:
```ruby
{ id: _, name: _ }
```

`api/users.babl`:
```ruby
{ users: each.partial('api/user') }
```

# <a name="pin"></a>`pin`

Keep a reference to the **current object** that can be re-used later.

# <a name="source"></a>`source(code, &block)`

Evaluate the provided `code` (or `block`) as if it was a BABL template, and append this template to the current chain. This operator is particularily useful to create [user-defined operators](templates#user_defined).

# <a name="static"></a>`static(value)`

Statically construct a chunck of JSON. It only accepts serializable objects [serializable objects](templates.md#rendering).
- JSON primitives
- Hashes
- Arrays

## Implicit form

An object is a JSON primitive if it is an instance of `String`, `Numeric`, `NilClass`, `TrueClass`, or `FalseClass`. All JSON primitives are accepted anywhere a `Babl::Template` is expected, and are handled by `static`.

```ruby
{
    str: { val: 'hello' },
    universe: 42,
    tired: true
}
```

is expanded as:

```ruby
object(
    str: object(val: static('hello')),
    universe: static(42),
    tired: static(true)
)
```

# <a name="switch"></a>`switch(condvals)`

Conditionally select between multiple templates based on conditions.

To do.

# <a name="typed"></a>`string`, `boolean`, `integer`, `number`

Type checking operators are a special kind of construction operators. They add checks at render time to ensure that the **current object** has the proper type.

It's worth noting that `nil` is never accepted by any of the typing operators. Consequently, the [`#nullable`](operators.md#nullable) operator must be used to declare nullable primitives.

## Usage

```ruby
object(
    intval: _.nullable.integer,
    boolval: _.boolean,
    strval: _.nullable.string,
    fltval: _.number
)
```

## JSON-Schema

Type constraints are always added to the generated documentation (see [JSON Schema](templates.md#json_schema)).

# <a name="with"></a>`with`

To do.