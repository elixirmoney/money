Money
=====

Elixir library for working with Money safer, easier, and fun, 
is an interpretation of the Fowler's Money pattern in fun.prog.

> "If I had a dime for every time I've seen someone use FLOAT to store currency, I'd have $999.997634" -- [Bill Karwin](https://twitter.com/billkarwin/status/347561901460447232)

In short: You shouldn't represent monetary values by a float. Wherever
you need to represent money, use this Money.

```elixir
alias Money, as: M

five_eur       = M.eur(500);
ten_eur        = M.add(five_eur, five_eur);
ten_eur_div_2  = M.divide(five_eur, 2);

M.equals?(ten_eur_div_2, five_eur); # true
M.zero?(five_eur);                  # false
M.currency_symbol(:USD)             # $
M.currency_symbol(M.afn(500))       # ؋ 
M.currency_name(M.afn(500))         # Afghani
M.to_string(M.cny(500))             # ¥ 5.00 
```

Installation
------------

Money comes with no dependencies, is still in dev state.

Install the library using [mix deps.get][1]. Add the following to your `mix.exs`:

```json
def deps do
  [ { :money, "~> 0.0.1-dev" } ]
end
```

Now run the `mix deps.get` command.

After you are done, run `mix deps.get` in your shell to fetch and compile Decimal. Start an interactive Elixir shell with `iex -S mix`.

```iex
iex> alias Money, as: M
nil
iex> M.usd(1000)
%Money{amount: 1000, currency: :USD}
iex> M.add(M.eur(500), M.eur(400))
%Money{amount: 900, currency: :EUR}
```

LICENSE
-------

MIT License please see the [LICENSE](./LICENSE) file.

ToDo
----

- doc
- options: round_up or round_down now is the simple round
- create the money type as struct 


[1]: http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html