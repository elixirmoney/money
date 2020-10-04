# Changelog

## Unreleased

## 1.8.0

### 🚀Enhancements

- Improves error message when Money.parse! fails
- Add Money.cmp/2 function
- Add decimal@v2.0.0 to optional list in mix.exs

### 🐛Bug Fixes

- Fix: avoic float rounding in Money.to_string
- Fix some type specs (did not include valid types)
- Fix Elixir 1.11.0 complain about variable usage
- Fix duplicate doc for Money.Currency.get/1


## 1.7.0

### 🚀Enhancements

- Add Elixir 1.9 and 1.10 to CI [#97]
- Support embedded schema for `Money.Ecto.Amount.Type` and `Money.Ecto.Map.Type` ecto types
- Support parsing `%Decimal{}` values in `parse/3` and `parse!/3` functions
- Support `Money.to_decimal/1` to return the value as `%Decimal{}`
- Add currency ISO 4217 numbers support
- `Money.equals?` no longer raises when comparing different currencies
- `Money.parse` and `Money.parse!` now accept any number as argument

## 1.6.1

### 🐛Bug Fixes

- Revert Money.Ecto.Amount.Type casting to integer. This behavior leads to the fact that the structures after casting and loading from the database are different. Details [#116](https://github.com/elixirmoney/money/issues/116)

## 1.6.0

### 🚀Enhancements

- Strip insignificant zeros [#76]
- Check for the new using block for Ecto.Type in Ecto 3.2 [#112]
- Fix delimeter typo [#113]
- Money.Ecto.Amount.Type now casting to integer [#114]

## 1.5.1

### 🐛Bug Fixes

- Fix Money.Ecto.Type casting

## 1.5.0

### 🚀Enhancements

- Allow adding custom currencies [#108]
- Configure custom_currencies at runtime rather than compile time [#111]
- Add Philippine Piso sign [#104]
- Add support to cast from atom-keyed maps [#110]
- Fix readme typos in usage subtract and divide typos [#109]
- Add dializer and fix warnings

### 🐛Bug Fixes

- Fix typos with Money.Ecto.Map.Type docs [#105]

## 1.4.0

Now hex is supported by an open organization and we are happy for new contributors and maintainers.

### 🚀Enhancements

- Add support multiple currencies with map(JSON) type [#101]
- Add support multiple currencies with PostgreSQL composite type [#96]
- Add new Ecto Type for Currency [#87]
- Add credo and fix styles [#103]
- Formatting codebase [#102]
- Move repo to OSS organization and fix repo links after transfer [#99]
- Add Elixir 1.8.1 to CI [#97]

### ⛔️Deprecations

- Deprecate `Money.Ecto.Type`, use `Money.Ecto.Amount.Type` module instead

### 🐛Bug Fixes

- Fix dividing negative one [#95]
- Fix cast in `Money.Ecto.Amount.Type` from money with currency other than a default [#100]

## 1.3.2

- Add Guaraní sign for PYG [#94]
- Add new Belarusian ruble [#92]

## 1.3.1

- Support ecto 3.0 [#91]

## 1.3.0

- Support elixir 1.6 and 1.7 versions [#90]
- Correct symbol for DKK [#86]
- Update supported elixir versions to 1.3 [#75]
- Fix deprecation warning for elixir 1.5 [#74]
- Add some more symbols for currencies [#71]
- Add some more symbols for currencies [#71]
- Fix official RUB symbol [#70]
- Adding a HexDoc link to the readme for faster linking to the docs [#68]
- Allow casting a Map of ecto's embeds_many [#66]

## 1.2.2

- Fixing Mexican and Colombian pesos names [#63]
- Add support currency exponents [#60]
- Add ability to retrieve all currencies

## 1.2.1

- Add Money.abs/1
- Add Money.neg/1
- Fix issues with Money.divide/2 and negative values [#57]
- Changes for clean compile on Elixir 1.4.1
- Changed sigil functions to macros for compile time expansion [#59]

## 1.2.0

- Add formatting option to hide fractional units [#47]
- Allow underscores in sigil [#48]

### 1.1.3

- Fix parsing amounts without a leading digit [#46]

### 1.1.2

- Bug fix: to_string with negative [#42]

### 1.1.1

- No changes

## 1.1.0

- Add formatting options [#36]
- Update parse to handle negative values [#39]
- Add support for Money.cast/1 for existing Money struct [#33]
- Add support for Money sigil ~M [#32]
- Add optional support for Phoenix.HTML.Safe [#29]

## 1.0.0

Initial release
