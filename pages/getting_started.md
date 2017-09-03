# Rails setup guide

BABL comes with its own ActionView's template handler supporting `*.babl` files.

## Installation

Add this line to your `Gemfile`:
```ruby
gem 'babl-json'
```

In order to activate Rails integration, BABL needs to be required *after* Rails. For instance, you can do:
```ruby
require 'rails'
require 'babl'
```

Alternatively, if BABL cannot be required before Rails for some reasons, you can call this later, when you know that Rails is loaded:
```ruby
require 'babl/railtie'
```

## Configuration (optional)

Create a new initializer `initializers/babl.rb`:

```ruby
Babl.configure do |config|
    # This path is used to find partials
    # (required only if you want to use partials)
    config.search_path = Rails.root.join('app', 'views')

    # Enable or disable pretty formatting of JSON outputs
    config.pretty = Rails.env.development?
end
```

## Hello world

Create a new template `app/views/my_resources/hello_world.babl` containing:
```ruby
object(
    answer_to_life: _
)
```

Create a new action/route in a controller:
```ruby
class MyResourcesController < ActionController::Base
    def hello_world
        render 'hello_world', locals: { answer_to_life: 42 }
    end
end
```

Call this route, you should get:

```js
{
    "answer_to_life": 42
}
```

Congratulations, BABL is ready to use !

----

Read [BABL concepts](concepts.md)