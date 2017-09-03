# Known issues

## Rails integration

This gem implements support of `*.babl` views in [Rails](https://github.com/rails/rails/).

Ideally, the template should be compiled once for all and re-used for all subsequent requests. In practice, today's implementation will re-compile the template at every request, because Rails templating mechanism doesn't make our life easy. Template compilation time is non negligible, and it could become a real problem with [code generation](https://github.com/getbannerman/babl/pull/21).

I will probably hack something soon in order to work around this issue.

## No recursion

BABL does not support recursive templates. According to my experience, it is not as useful as one mights imagine in practice.

I think we should add a way for a template to reference itself. For instance, here is how we could serialize a binary tree:

```ruby
object(
    root: template { |tree_node|
        object(
            name: _,
            left: _.nullable.(tree_node),
            right: _.nullable.(tree_node)
        )
    }
}
```

I do not plan to work on that feature in the near future.
