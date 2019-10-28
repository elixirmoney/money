# Money

[![Build Status](https://travis-ci.org/elixirmoney/money.svg?branch=master)](https://travis-ci.org/elixirmoney/money)

Elixir library for working with Money safer, easier, and fun,
is an interpretation of the Fowler's Money pattern in fun.prog.

> "If I had a dime for every time I've seen someone use FLOAT to store currency, I'd have \$999.997634" -- [Bill Karwin](https://twitter.com/billkarwin/status/347561901460447232)

In short: You shouldn't represent monetary values by a float. Wherever
you need to represent money, use `Money`.

Documentation can be found at [https://hexdocs.pm/money/Money.html](https://hexdocs.pm/money/Money.html) on [HexDocs](https://hexdocs.pm)

## USAGE

```elixir
five_eur         = Money.new(500, :EUR)             # %Money{amount: 500, currency: :EUR}
ten_eur          = Money.add(five_eur, five_eur)    # %Money{amount: 10_00, currency: :EUR}
hundred_eur      = Money.multiply(ten_eur, 10)      # %Money{amount: 100_00, currency: :EUR}
ninety_nine_eur  = Money.subtract(hundred_eur, 100) # %Money{amount: 99_00, currency: :EUR}
shares           = Money.divide(ninety_nine_eur, 2) # [%Money{amount: 4950, currency: :EUR}, %Money{amount: 4950, currency: :EUR}]

Money.equals?(five_eur, Money.new(500, :EUR)) # true
Money.zero?(five_eur);                        # false
Money.positive?(five_eur);                    # true

Money.Currency.symbol(:USD)                   # $
Money.Currency.symbol(Money.new(500, :AFN))   # ؋
Money.Currency.name(Money.new(500, :AFN))     # Afghani

Money.to_string(Money.new(500, :CNY))         # ¥ 5.00
Money.to_string(Money.new(1_234_56, :EUR), separator: ".", delimiter: ",", symbol: false)
"1.234,56"
Money.to_string(Money.new(1_234_56, :USD), fractional_unit: false)  # "$1,234"
Money.to_string(Money.new(1_234_50, :USD), strip_insignificant_zeros: true)  # "$1,234.5"
```

### Serialization to database with single currency

Bring `Money` to your Ecto project.
The underlying database type is `integer`

1. Set a default currency in `config.ex`:

```elixir
config :money,
  default_currency: :USD
```

2. Create migration with integer type:

```elixir
create table(:jobs) do
  add :amount, :integer
end
```

3. Create schema using the `Money.Ecto.Amount.Type` Ecto type (don't forget run `mix ecto.migrate`):

```elixir
schema "jobs" do
  field :amount, Money.Ecto.Amount.Type
end
```

3. Save to the database:

```elixir
iex(1)> Repo.insert %Job{amount: Money.new(100, :USD)}
[debug] QUERY OK db=90.7ms queue=0.1ms
INSERT INTO "jobs" ("amount","inserted_at","updated_at") VALUES ($1,$2,$3) RETURNING "id" [100, {{2019, 2, 12}, {7, 29, 8, 589489}}, {{2019, 2, 12}, {7, 29, 8, 593185}}]
{:ok,
 %MoneyTest.Offers.Job{
   __meta__: #Ecto.Schema.Metadata<:loaded, "jobs">,
   amount: %Money{amount: 100, currency: :USD},
   id: 1,
   inserted_at: ~N[2019-02-12 07:29:08.589489],
   updated_at: ~N[2019-02-12 07:29:08.593185]
 }}
```

4. Get from the database:

```elixir
iex(2)> Repo.one(Job, limit: 1)
[debug] QUERY OK source="jobs" db=1.8ms
SELECT j0."id", j0."amount", j0."inserted_at", j0."updated_at" FROM "jobs" AS j0 []
%MoneyTest.Offers.Job{
  __meta__: #Ecto.Schema.Metadata<:loaded, "jobs">,
  amount: %Money{amount: 100, currency: :USD},
  id: 1,
  inserted_at: ~N[2019-02-12 07:29:08.589489],
  updated_at: ~N[2019-02-12 07:29:08.593185]
}
```

### Serialization to PostgreSQL with multiple currency

`Money.Ecto.Composite.Type` Ecto type represents serialization of `Money.t` to [PostgreSQL Composite Types](https://www.postgresql.org/docs/11/rowtypes.html) with saving currency.

1. Create migration with custom type:

```elixir
  def up do
    execute """
    CREATE TYPE public.money_with_currency AS (amount integer, currency char(3))
    """
  end

  def down do
    execute """
    DROP TYPE public.money_with_currency
    """
  end
```

2. Then use created custom type(`money_with_currency`) for money field:

```elixir
  def change do
    alter table(:jobs) do
      add :price, :money_with_currency
    end
  end`
```

3. Create schema using the `Money.Ecto.Composite.Type` Ecto type (don't forget run `mix ecto.migrate`):

```elixir
schema "jobs" do
  field :price, Money.Ecto.Composite.Type
end
```

3. Save to the database:

```elixir
iex(1)> Repo.insert %Job{price: Money.new(100, :JPY)}
[debug] QUERY OK db=7.7ms
INSERT INTO "jobs" ("price","inserted_at","updated_at") VALUES ($1,$2,$3) RETURNING "id" [{100, "JPY"}, {{2019, 2, 12}, {8, 7, 44, 729114}}, {{2019, 2, 12}, {8, 7, 44, 729124}}]
{:ok,
 %MoneyTest.Offers.Job{
   __meta__: #Ecto.Schema.Metadata<:loaded, "jobs">,
   id: 6,
   inserted_at: ~N[2019-02-12 08:07:44.729114],
   price: %Money{amount: 100, currency: :JPY},
   updated_at: ~N[2019-02-12 08:07:44.729124]
 }}
```

4. Get from the database:

```elixir
iex(2)> Repo.one(Job, limit: 1)
[debug] QUERY OK source="jobs" db=1.4ms
SELECT j0."id", j0."price", j0."inserted_at", j0."updated_at" FROM "jobs" AS j0 []
%MoneyTest.Offers.Job{
  __meta__: #Ecto.Schema.Metadata<:loaded, "jobs">,
  id: 6,
  inserted_at: ~N[2019-02-12 08:07:44.729114],
  price: %Money{amount: 100, currency: :JPY},
  updated_at: ~N[2019-02-12 08:07:44.729124]
}
```

### Serialization to database (JSON) with multiple currency

`Money.Ecto.Map.Type` Ecto type represents serialization of `Money.t` to map(JSON) with saving currency.

1. Create migration with map type:

```elixir
  def change do
    alter table(:jobs) do
      add :price, :map
    end
  end
```

2. Create schema using the `Money.Ecto.Map.Type` Ecto type (don't forget run `mix ecto.migrate`):

```elixir
schema "jobs" do
  field :price, Money.Ecto.Map.Type
end
```

3. Save to the database:

```elixir
iex(1)> Repo.insert %Job{price: Money.new(100, :JPY)}
[debug] QUERY OK db=4.6ms
INSERT INTO "jobs" ("price","inserted_at","updated_at") VALUES ($1,$2,$3) RETURNING "id" [%{"amount" => 100, "currency" => "JPY"}, {{2019, 2, 26}, {9, 40, 14, 381721}}, {{2019, 2, 26}, {9, 40, 14, 381730}}]
{:ok,
 %MoneyTest.Offers.Job{
   __meta__: #Ecto.Schema.Metadata<:loaded, "jobs">,
   id: 9,
   inserted_at: ~N[2019-02-26 09:40:14.381721],
   price: %Money{amount: 100, currency: :JPY},
   updated_at: ~N[2019-02-26 09:40:14.381730]
 }}
```

4. Get from the database:

```elixir
iex(8)> Repo.one(Job, limit: 1)
[debug] QUERY OK source="jobs" db=2.0ms
SELECT j0."id", j0."price", j0."inserted_at", j0."updated_at" FROM "jobs" AS j0 []
%MoneyTest.Offers.Job{
  __meta__: #Ecto.Schema.Metadata<:loaded, "jobs">,
  id: 10,
  inserted_at: ~N[2019-02-26 09:40:45.205076],
  price: %Money{amount: 100, currency: :JPY},
  updated_at: ~N[2019-02-26 09:40:45.205084]
}
```

### Money.Sigils

```elixir
# Sigils for Money
import Money.Sigils

iex> ~M[1000]USD
%Money{amount: 1000, currency: :USD}

# If you have a default currency configured (e.g. to GBP), you can do
iex> ~M[1000]
%Money{amount: 1000, currency: :GBP}
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

### Phoenix.HTML.Safe

Bring `Money` to your Phoenix project.
If you are using Phoenix, you can include money objects directly into your output and they will be correctly escaped.

```elixir
<b><%= Money.new(12345,67, :GBP) %></b>
```

## INSTALLATION

Money comes with no required dependencies.

Add the following to your `mix.exs`:

```elixir
def deps do
  [{:money, "~> 1.4"}]
end
```

then run [`mix deps.get`](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix).

## CONFIGURATION

You can set a default currency and default formatting preferences as follows:

```elixir
config :money,
  default_currency: :EUR,
  separator: ".",
  delimiter: ",",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false,
  fractional_unit: true,
  strip_insignificant_zeros: false
```

Then you don’t have to specify the currency.

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 123450, currency: :EUR}
iex> to_string(amount)
"1.234,50"
```

Here is another example of formatting money:

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 123450, currency: :EUR}
iex> Money.to_string(amount, symbol: true, symbol_on_right: true, symbol_space: true)
"1.234,50 €"
```

## Adding your own currencies

In some cases we can need to add not common currencies, like crypto currencies or others.
In order to add your own currencies you have to add them in the config file following this format:

```elixir
config :money,
  custom_currencies: [
    BTC: %{name: "Bitcoin", symbol: "₿", exponent: 2},
    GCS: %{name: "Galactic Credit Standard", symbol: "gcs", exponent: 0}
  ]
```

## Troubleshooting

### Validating amount in Ecto changeset

When using the `Money.Ecto.Amount.Type` type, it may seem that a simple value validation should work, for example:

```elixir
schema "jobs" do
  field :amount, Money.Ecto.Amount.Type
end

def changeset(struct, params \\ %{}) do
  struct
  |> cast(params, [:amount])
  |> validate_number(:amount, [greater_than: 0])
end
```

But this kind of validation will not work, since under the hood `Money.Ecto.Amount.Type` has the structure `%Money{amount: ..., currency: ...}`. To validate the data in this case, we recommend adding custom validation that matches your logic.

Example:

```elixir
def changeset(struct, params \\ %{}) do
  struct
  |> cast(params, [:amount])
  |> validate_money(:amount)
end

defp validate_money(changeset, field) do
  validate_change(changeset, field, fn
    _, %Money{amount: amount} when amount > 0 -> []
    _, _ -> [amount: "must be greater than 0"]
  end)
end
```

## LICENSE

MIT License please see the [LICENSE](./LICENSE) file.
