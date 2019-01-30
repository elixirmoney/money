# Changelog

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
