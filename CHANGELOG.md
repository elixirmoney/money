# Changelog

## Unreleased

- Fix the `Money.Currency` bang functions (`exponent!/1`, `symbol!/1` and others) looping forever
  when given a `Money` struct with an unknown currency: building the error message called
  `Money.to_string/2`, which raised the same error again. `Money.to_string/2` for such a struct now
  raises `ArgumentError` naming the currency instead of an unrelated `ArithmeticError`.
- The `~M` sigil accepts a lowercase currency code, as in `~M[1000]usd`, like `Money.new/2` does.
- Clearer error messages: `Money.Currency.to_atom/1` (and so `Money.new/2`) names the currency it
  was given instead of printing an empty name for an unknown string or number, and `Money.parse/1`
  without a default currency mentions `Money.parse/1` instead of `Money.new/1`.
- Fix `Money.Currency.sub_units_count!/1` computing powers of ten with floats, which was off for
  custom currencies with an exponent of 23 or more: exponent 24 gave `999999999999999983222784`.
- Fix `Money.to_string/2` rendering a negative amount as `"- 1.00"` when there is no symbol and
  `symbol_space: true`, such as with `symbol: false` or a currency with an empty symbol (XAU).
- Fix `Money.parse/3` raising `ArgumentError` for a number or Decimal with an unknown currency. It
  now returns `:error`, as it already did for strings. `Money.parse!/3` still raises.
- `Money.Ecto.NumericCurrency.Type.dump/1` accepts a currency string, ISO number or `Money` struct,
  as `cast/1` does. It returned `:error` for them.
- Fix `Money.Ecto.Map.Type.load/1` raising `FunctionClauseError` for an amount stored as a float,
  as some JSON columns return it. A whole float such as `100.0` now loads, and malformed data
  returns `:error`.
- Fix the Ecto types' `cast/1` raising instead of returning `:error` for a non-integer amount or an
  unknown currency, such as `%{"amount" => "10.50"}` or `{100, "XXXX"}`, so changesets get a
  validation error instead of crashing.
- Document that `Money` can't be passed as the sorter module to `Enum.sort/2`, `Enum.min/2` or
  `Enum.max/2`, since `Money.compare/2` returns `-1`, `0` or `1`, and show sorting with `Money.cmp/2`.
- Fix currency lookup by ISO number returning a currency that depends on VM state for numbers
  shared by two currencies, so `Money.Ecto.NumericCurrency.Type` could store `:BYN` and load it
  back as `:BYR`.
  - A number shared by a replaced currency and its successor now always returns the successor:
    532 returns `:XCG` (not `:ANG`) and 933 returns `:BYN` (not `:BYR`).
- Fix currency lookup by ISO number (`Money.Currency.get(840)`, `Money.Ecto.NumericCurrency.Type`)
  returning `nil` for every number when a custom currency without a `:number` is configured, as in
  the README's custom currency example.
- Fix `Money.parse/3` returning a wrong amount for a string that isn't a single number once
  symbols, codes and separators are removed; it now returns `:error`. With Decimal 2 or later,
  or without Decimal, the unparsed rest was ignored, so `"1.2.3"` gave 1.20, `"10-20"` gave
  10.00, and `"(10.00)"` gave a positive 10.00. A digit inside parentheses now returns `:error`;
  parentheses without digits, as in `"$10.00 (USD)"`, are still ignored.
- Fix `Money.parse/3` reading the "E" of a currency code before the amount as an exponent:
  `"EUR 10"`, `"SEK 10"` and `"EGP 1.5"` returned `:error`. An `e`/`E` is now kept only after a
  digit or the delimiter and before a (signed) digit, as in `"1.5e3"`.
- Fix `Money.divide/2` returning shares with the wrong sign when the amount is smaller than the
  denominator: `Money.divide(Money.new(-2, :USD), 3)` returned `[1, -1, 0]` (summing to 0) and
  `Money.divide(Money.new(1, :USD), -3)` returned `[1, 0, 0]`.
- Fix `Money.add/2` and `Money.subtract/2` with a float ignoring the currency's exponent.
  The float was always multiplied by 100, so `Money.add(Money.new(100, :JPY), 5.0)` added 500 yen
  and `Money.add(Money.new(0, :BHD), 1.5)` added 0.150 BHD.
- Bound Decimal exponents in `Money.parse/3`, `Money.multiply/2` and `Money.div/2`, whatever
  Decimal version is installed. With Decimal before 3.0, input such as `"1e1000000"` built a
  million-digit integer and took seconds (denial of service on untrusted input).
  - `Money.parse/3` returns `:error` when the value in sub-units is `1e1000` or more in
    magnitude (an amount of more than 1000 digits) or below `1e-1000`.
  - `Money.multiply/2` and `Money.div/2` raise `ArgumentError` for a non-zero Decimal
    multiplier or divisor outside that range.
- **Breaking:** Fix TND and CVE exponents to match ISO 4217 (#259)
  - TND (Tunisian Dinar) now has exponent 3 instead of 2 (1 dinar = 1000 millimes)
  - CVE (Cabo Verde Escudo) now has exponent 2 instead of 0
  - Stored integer amounts change meaning: an amount created as `Money.new(1500, :TND)` was
    15.00 TND and is now 1.500 TND. Multiply stored TND amounts by 10 and CVE amounts by 100,
    or keep the old exponent with `config :money, custom_currencies: [TND: %{...}]`.
- **Breaking:** Require Elixir 1.15 or later (was 1.11)
- Update dev and test dependencies (credo 1.7, ex_doc 0.40, blend 0.5, dialyxir 1.4.9) and test against Decimal 3 in CI
- Add missing ISO 4217 currencies: CHE, CHW, UYW, VED, XAD, ZWG (#257)
- Add Money.zero/1 to create a zero amount (#255)
- Keep integer division inside the integer range for large amounts (#254)
- Add XCG currency (Caribbean guilder) (#251)
- Add guards for Money: `is_money/1`, `is_zero/1`, `is_positive/1`, `is_negative/1` (#250)
- Pin CI runner to ubuntu-24.04 (#256)

## 1.15.0 – 2026-05-18

- Allow Decimal 3.0 (#249)
- Add Money.div/2 for single-value division with rounding (#245)
- Fix currency symbols (#241)
- Fix CI runners and minimum OTP version (#243)

## 1.14.0 – 2025-03-10

- Add support parsing scientific notation
- Fix elixir 1.18 type warning (#239)

## 1.13.1 – 2024-07-10

- Fix release not including blend (which is a dev tool) (#229)

## 1.13.0 – 2024-07-09

- Add custom_display_options configuration (#225)
- Update Money.parse/1 to work with decimal ~> 1.2 and ~> 2.0 (#227)

## 1.12.4 – 2024-01-04

- Allow phoenix_html 4.0 (#212)

## 1.12.3 – 2023-08-23

- Fix map_type dump typespec (#204)
- Add SLE which is the new currency in Sierra Leone (#203)
- Bugfix: {Currency.Type.dump/1} missing ISO string support (#201)

## 1.12.2 – 2023-01-19

- Better error messages for `Money.add` and `Monet.subtract` (#191)

## 1.12.1 – 2022-11-23

This release rolls back the breaking change in Money.parse .  
Support exponential notation feature will be added in the next major release.

### 🐛Bug Fixes

- Remove support exponential notation for Money.parse (#192) (#198)

## 1.12.0 – 2022-11-18

### 🚀Enhancements

- Fix PEN currency symbol (#191)
- Migrate from travis ci to github actions (#193)
- Support exponential notation for Money.parse (#192)
- Add readme section about using Decimal (#194)
- Bump dependencies (#186)(#187)(#196)

## 1.11.0 – 2022-08-15

### 🚀Enhancements

- Suggest using varchar instead of char on postgres (#178)
- Fix symbol_space with negative values (#180)
- Fix to_string to use the minus_sign_first option (#181)
- Adds support for strip_insignificant_fractional_unit option to to_string (#183)
- Fix Canadian and Singaporean Dollar symbols (#185)

## 1.10.0 – 2022-04-10

### 🚀Enhancements

- Allow rounding Money values with Decimal (#177)
- Parse with Decimal if present (#176)
- Display minus sign before the currency symbol (fixes #154) (#173)

## 1.9.0

### 🚀Enhancements

- Add Bolivar Soberano (#155)
- Improve Money.to_decimal to respect decimal places (#157)
- Add :code option for to_string rendering (#161)
- Allow Phoenix HTML 2.0 or 3.0 (#168)
- Support multiplying money by a decimal (#167)
- Use the rounding algorithm set in Decimal's context (#166)

### 🐛Bug Fixes

- Fix bug when using Money.to_decimal with amount 0 (#158)

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
