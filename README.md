# Money [![Build Status](https://travis-ci.org/liuggio/money.svg)](https://travis-ci.org/liuggio/money)

Elixir library for working with Money safer, easier, and fun,
is an interpretation of the Fowler's Money pattern in fun.prog.

> "If I had a dime for every time I've seen someone use FLOAT to store currency, I'd have $999.997634" -- [Bill Karwin](https://twitter.com/billkarwin/status/347561901460447232)

In short: You shouldn't represent monetary values by a float. Wherever
you need to represent money, use `Money`.

## USAGE

```elixir
five_eur         = Money.new(500, :EUR)             # %Money{amount: 500, currency: :EUR}
ten_eur          = Money.add(five_eur, five_eur)    # %Money{amount: 10_00, currency: :EUR}
hundred_eur      = Money.multiply(ten_eur, 10)      # %Money{amount: 100_00, currency: :EUR}
ninety_nine_eur  = Money.subtract(hundred_eur, 1)   # %Money{amount: 99_00, currency: :EUR}
shares           = Money.divide(ninety_nine_eur, 2)
[%Money{amount: 50, currency: :EUR}, %Money{amount: 49, currency: :EUR}]

Money.equals?(five_eur, Money.new(500, :EUR)) # true
Money.zero?(five_eur);                        # false
Money.positive?(five_eur);                    # true

Money.Currency.symbol(:USD)                   # $
Money.Currency.symbol(Money.new(500, :AFN))   # ؋
Money.Currency.name(Money.new(500, :AFN))     # Afghani

Money.to_string(Money.new(500, :CNY))         # ¥ 5.00
Money.to_string(Money.new(1_234_56, :EUR), separator: ".", delimeter: ",", symbol: false)
"1.234,56"
```

### Money.Currency

```elixir
# Currency convenience methods
import Money.Currency, only: [usd: 1, eur: 1, afn: 1]

iex> usd(100_00)
%Money{amount: 10000, currency: :USD}
iex> eur(100_00)
%Money{amount: 10000, currency: :EUR}
iex> afn(100_00)
%Money{amount: 10000, currency: :AFN}

Money.Currency.symbol(:USD)     # $
Money.Currency.symbol(afn(500)) # ؋
Money.Currency.name(afn(500))   # Afghani
Money.Currency.get(:AFN)        # %{name: "Afghani", symbol: "؋"}
```

### Money.Ecto.Type

Bring `Money` to your Ecto project.
The underlying database type is `integer`

```elixir
# migration
create table(:my_table) do
  add :amount, :integer
end

# model/schema
schema "my_table" do
  field :amount, Money.Ecto.Type
end
```

## INSTALLATION

Money comes with no required dependencies.

Add the following to your `mix.exs`:

```elixir
def deps do
  [{:money, "~> 1.0.0-beta"}]
end
```
then run [`mix deps.get`](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix).

## CONFIGURATION

You can set a default currency and default formatting preferences as follows:

```elixir
config :money,
  default_currency: :EUR,
  separator: ".",
  delimeter: ",",
  symbol: false
```

Then you don’t have to specify the currency.

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 1000, currency: :EUR}
iex> to_string(amount)
"1.234,50"
```

## LICENSE

MIT License please see the [LICENSE](./LICENSE) file.
