require 'babl/builder'
require 'babl/operators'

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
