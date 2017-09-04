# Design rationale

There already exists many solutions for creating JSON views:
- [RABL](https://github.com/nesquena/rabl)
- [JBuilder](https://github.com/rails/jbuilder)
- [Grape Entity](https://github.com/ruby-grape/grape-entity)
- [AMS](https://github.com/rails-api/active_model_serializers)
- [Jb](https://github.com/amatsuda/jb)
- [Roar](https://github.com/trailblazer/roar)
- Custom code

Do we need another one ? Yes, assuming that it brings something the other don't have.

Is BABL better than the all others ? Not necessarily. It is all about tradeoffs and opinions.

## Rigid structure

Flexibility of BABL templates is limited on purpose.

- There is no built-in way to create a JSON object having dynamic keys.
    - It is harder to document to API consumers, because the structure can change.
    - Slightly harder to parse on client side, especially if they are deserialized into classes in a statically typed language.

- BABL doesn't let the user manipulate its models directly. Instead, he has to to tell BABL what to do with them using a limited vocabulary.
    - Being limited to do simple logic in views is an acceptable compromise. It is a permanent incentive to push business logic back to your code.
    - Letting BABL call methods on models itself is what makes automatic preloading possible (see N+1 section).

Flexibility always comes at a price.

## Functional / Immutable DSL

RABL and Jbuilder are imperative DSLs [1]:
- Each command mutates the state of the DSL context object.
- The return value of each command is ignored.
- The final return value is the original context object.

On the other side, BABL is a functional DSL (like `ActiveRecord`, for instance):
- The original DSL context object is immutable.
- Each command returns the next DSL context object.
- The final return value is the value returned by the last command.

I'm personally convinced that dealing only with immutable objects leads to less bugs. Composition & chaining are trivial because template instances cannot change. Similarly, it is safe to store templates' fragments into
variables and re-use them at any place.

This is breath of fresh air in Ruby world, where everything can change at any time. I am not a big fan of Ruby.

## Performances

A BABL template describes a transformation from an object graph to JSON data. It doesn't dictate *how* this transformation should take place in practice.

This approach gives a lot of freedom to BABL. It may decide to simplify the template during compilation as long as it can guarantee that the output will stay the same. A typical example is when you extend a partial to add properties to an object.

```ruby
# Example using #extends to a add property to a partial.
object(
    users: _.extends(
        'views/api/users/_user',
        devices: _.each.object(:id, :description)
    )
)

# The partial is inlined during compilation.
object(
    users: _.merge(
        object(:id, :name),
        object(devices: _.each.object(:id, :description))
    )
)

# BABL found an equivalent (but faster) way to rewrite the template without using #merge
# and creating temporary objects.
object(
    users: _.object(:id, :name, devices: _.each.object(:id, :description))
)
```

Today a template is compiled into a node tree. Each node is responsible for rendering a template fragment. In the future, BABL will transform templates directly into [specialized Ruby code](https://github.com/getbannerman/babl/pull/21). I hope to make BABL the fastest Ruby-based JSON template engine. 😎

## N+1

It is hard to get rid of N+1 issues without tightly coupling controllers with views. In controllers, you need to make sure you didn't forget something in `preload(...)`, and hope that you didn't load an association needlessly. Basically, we would like to have an automated way of calling `preload(...)`.

There already are some gems to cope with this problem:
- [Bullet](https://github.com/flyerhzm/bullet):

    Produce warnings every time a preload is missing or un-used. Still require human time to fix detected issues.

- [Goldiloader](https://github.com/salsify/goldiloader):

    Monkey-patch Rails to preload everything on-the-fly, by making assumptions about access patterns. Quite invasive in my opinion and it has some limitations.

In order to alleviate this issue, a BABL template statically exposes all the properties it will need to access during rendering. It makes it possible to write a preloader not only for Rails, but for anything you would like.

At Bannerman, we developed **Preeloo**. It natively supports ActiveRecord associations, computed columns, and custom preloadable properties. Unfortunately, it hasn't been released publicly yet because it still has severe bugs and limitations.

[1]: Functional / imperative DSL definitions are taken from [docile](https://github.com/ms-ati/docile/blob/master/lib/docile.rb).