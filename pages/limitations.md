# Known issues

## Rails integration

This gem implements support of `*.babl` views in [Rails](https://github.com/rails/rails/).

In theory, the template could be compiled once for all and re-used for subsequent requests. In practice, today's implementation will re-compile the template at every request, because Rails templating mechanism doesn't make our life easy.

If it turns out to be a performance bottleneck, I will probably hack something to work around this issue.

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

I don't plan to work on that feature in the near future.

## MRI Only

BABL depends on [Oj](https://github.com/ohler55/oj) to emit JSON. This gem depends on MRI's native extensions, which is why BABL only works on MRI.

I already planned to replace [Oj](https://github.com/ohler55/oj) by [multi_json](https://github.com/intridea/multi_json) soon.
