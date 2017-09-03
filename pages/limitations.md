# Limitations

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
