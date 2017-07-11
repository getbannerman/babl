# BABL Changelog

## 0.2.0 (July 11, 2017)

- Added support for producing documentation using [JSON-Schema](http://json-schema.org/).
- Improved some error messages occurring during rendering phase.
- Stricter validation of templates passed to the `merge` operator. Compilation will fail if at least one of them is not producing object.

## 0.1.4 (July 6, 2017)

- Added operator `extends`, to simplify the common usage pattern `merge(partial(...), ...)`.

## 0.1.3 (June 19, 2017)

- Added operator `null`, in order to make any JSON file a valid BABL template.

## 0.1.2 (May 22, 2017)

- Fixed a bug in `call(primitive)`
- Improved test suite

## 0.1.1 (May 16, 2017)

- First released version