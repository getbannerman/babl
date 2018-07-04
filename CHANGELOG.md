# Changelog

## 0.5.5 (July 4, 2018)
- Reduce template compilation time:
  - Faster `deep_merge` implementation (#89)
  - Fix: dependencies were computed multiple times in some cases (#90)

## 0.5.4 (May 29, 2018)
- Slightly improve rendering speed. [#87](https://github.com/getbannerman/babl/pull/87)
- Implement support for "named pins". [#88](https://github.com/getbannerman/babl/pull/88)

## 0.5.3 (April 24, 2018)
- Reduced number of object allocations during rendering. [#85](https://github.com/getbannerman/babl/pull/85)

## 0.5.2 (April 6, 2018)
- Improve JSON-Schema generation: simplify handling of nullable properties. [#83](https://github.com/getbannerman/babl/pull/83)

## 0.5.1 (April 6, 2018)
- Improve JSON-Schema generation: avoid nesting multiple `enum` inside `anyOf`. [#82](https://github.com/getbannerman/babl/pull/82)

## 0.5.0 (October 27, 2017)
- Revamp handling of partials. Breaking changes:
    - `partial` becomes a terminal operator.
    - Partials are now resolved during compilation instead of immediately.
    - Replaced `Babl.config.search_path` by `Babl.config.lookup_context`. Use `Babl::AbsoluteLookupContext`
    to get the old behavior.

    See [#75](https://github.com/getbannerman/babl/pull/75)

- New operator: `using`, to cleanly extend BABL with user-defined operators. [#76](https://github.com/getbannerman/babl/pull/76)
- Fix: `BABL::Template` is not a subclass of `Struct` anymore. It was causing namespace pollution. [#77](https://github.com/getbannerman/babl/pull/77)

## 0.4.0 (October 3, 2017)
- Fix: constant propagation was not always working with `merge`. [#73](https://github.com/getbannerman/babl/pull/73)
- New operator: `concat`. Similar to `merge`, but for `Array`s. [#72](https://github.com/getbannerman/babl/pull/72)

## 0.3.4 (September 30, 2017)
- Validate parameters passed to `source()` [#62](https://github.com/getbannerman/babl/pull/62)
- More consistent handling of `Symbol`s. [#63](https://github.com/getbannerman/babl/pull/63)
- Defensively copy parameters passed to operators, in order to guarantee that template's behavior cannot change. [#65](https://github.com/getbannerman/babl/pull/65)
- Type-checking assertion `string` allows symbols. [#66](https://github.com/getbannerman/babl/pull/66)
- Re-enable dependency tracking if `parent` is used after `with`. [#67](https://github.com/getbannerman/babl/pull/67)
- Optimize away multiple invocations of `nullable`. [#70](https://github.com/getbannerman/babl/pull/70)

## 0.3.3 (September 20, 2017)
- Forward method calls to the original receiver of the block passed to `source`. [#60](https://github.com/getbannerman/babl/pull/60)

## 0.3.2 (September 20, 2017)
- Fix a schema merging bug (`{ a?: 1 } | { a: 2 }` produces `{ a?: 1 | 2 }`  instead of `{ a: 2 }`). [#57](https://github.com/getbannerman/babl/pull/57)
- Merge schemas more aggressively. [#58](https://github.com/getbannerman/babl/pull/58)

## 0.3.1 (September 4, 2017)
- Ensure `BigDecimal` is serialized into JSON float, regardless of the JSON backend chosen. [#50](https://github.com/getbannerman/babl/pull/50)

## 0.3.0 (September 4, 2017)
- Added documentation pages.
- Integrate Coveralls with CI.
- Allow serialization of `Symbol`s.
- Replace [Oj](https://github.com/ohler55/oj) by [MultiJson](https://github.com/intridea/multi_json).
- Added operator: [`null?`](pages/operators.md#is_null).
- Compilation optimizations: constant propagation & eager evaluation.
- Added a new setting `Babl.config.cache_templates` (default to false). If enabled, template compiled by the Rails integration will be cached forever.
- Added a performance benchmark against existing tools (only JBuilder for now).
- Minor performance improvements (for `nullable`).

## 0.2.6 (August 28, 2017)
- Enable `frozen_string_literal` everywhere (should be enabled by default in Ruby 3)
- Minor performance improvements (for `nav` and `with`).

## 0.2.5 (August 21, 2017)
- Made `string`, `boolean`, `number` and `integer` terminal operators.
- Avoid evaluating overridden properties in simple cases (`merge(object(...), object(...)))`).
- Minor performance improvements.

## 0.2.4 (August 17, 2017)
- Improved JSON-Schema generation, especially when `switch` is used inside `merge`.
- Added a benchmark for evaluating performance improvements.
- Performance improvements.
- Removed unneeded files to reduce gem size.

## 0.2.3 (July 21, 2017)
- Try to simplify JSON-Schema when types are specified.
- Cut out dependency on [Values](https://github.com/tcrayford/Values).

## 0.2.2 (July 13, 2017)

- Added four typing operators: `integer`, `number`, `string` and `boolean`.

## 0.2.1 (July 11, 2017)

- Fix: array serialization is broken.

## 0.2.0 (July 11, 2017)

- Added support for producing documentation using [JSON-Schema](http://json-schema.org/).
- Improved some error messages occurring during rendering phase.
- Stricter validation of templates passed to the `merge` operator. Compilation will fail if at least one of them is not producing object.

## 0.1.4 (July 6, 2017)

- Added operator `extends`, to simplify the common usage pattern `merge(partial(...), ...)`.

## 0.1.3 (June 19, 2017)

- Added operator `null`, in order to make any JSON file a valid BABL template.

## 0.1.2 (May 22, 2017)

- Fixed a bug in `call(primitive)`.
- Improved test suite.

## 0.1.1 (May 16, 2017)

- First released version.
