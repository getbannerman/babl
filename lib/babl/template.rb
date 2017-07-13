require 'babl/operators/array'
require 'babl/operators/call'
require 'babl/operators/continue'
require 'babl/operators/default'
require 'babl/operators/dep'
require 'babl/operators/each'
require 'babl/operators/enter'
require 'babl/operators/extends'
require 'babl/operators/merge'
require 'babl/operators/nav'
require 'babl/operators/null'
require 'babl/operators/nullable'
require 'babl/operators/object'
require 'babl/operators/parent'
require 'babl/operators/partial'
require 'babl/operators/pin'
require 'babl/operators/source'
require 'babl/operators/static'
require 'babl/operators/switch'
require 'babl/operators/typed'
require 'babl/operators/with'

require 'babl/builder/template_base'

module Babl
    class Template < Babl::Builder::TemplateBase
        include Operators::Array::DSL
        include Operators::Call::DSL
        include Operators::Continue::DSL
        include Operators::Default::DSL
        include Operators::Dep::DSL
        include Operators::Each::DSL
        include Operators::Enter::DSL
        include Operators::Extends::DSL
        include Operators::Merge::DSL
        include Operators::Nav::DSL
        include Operators::Null::DSL
        include Operators::Nullable::DSL
        include Operators::Object::DSL
        include Operators::Parent::DSL
        include Operators::Partial::DSL
        include Operators::Pin::DSL
        include Operators::Source::DSL
        include Operators::Static::DSL
        include Operators::Switch::DSL
        include Operators::Typed::DSL
        include Operators::With::DSL
    end
end
