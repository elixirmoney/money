defmodule Money do
  import Kernel, except: [abs: 1, round: 1]

  @moduledoc """
  Defines a `Money` struct along with convenience methods for working with currencies.

  ## Examples

      iex> money = Money.new(500, :USD)
      %Money{amount: 500, currency: :USD}
      iex> money = Money.add(money, 550)
      %Money{amount: 1050, currency: :USD}
      iex> Money.to_string(money)
      "$10.50"

  ## Configuration

  You can set defaults in your Mix configuration to make working with `Money` a little easier.

      config :money,
        default_currency: :EUR,                    # this allows you to do Money.new(100)
        separator: ".",                            # change the default thousands separator for Money.to_string
        delimiter: ",",                            # change the default decimal delimiter for Money.to_string
        symbol: false,                             # don’t display the currency symbol in Money.to_string
        symbol_on_right: false,                    # position the symbol
        symbol_space: false,                       # add a space between symbol and number
        fractional_unit: true,                     # display units after the delimiter
        strip_insignificant_zeros: false,          # don’t display the insignificant zeros or the delimiter
        code: false,                               # add the currency code after the number
        minus_sign_first: true,                    # display the minus sign before the currency symbol for Money.to_string
        strip_insignificant_fractional_unit: false # don't display the delimiter or fractional units if the fractional units are only insignificant zeros

  """

  @type t :: %__MODULE__{
          amount: integer,
          currency: atom
        }

  defstruct amount: 0, currency: :USD

  alias Money.Currency
  alias Money.DisplayOptions
  alias Money.ParseOptions

  @spec new(integer) :: t
  @doc ~S"""
  Create a new `Money` struct using a default currency.
  The default currency can be set in the system Mix config.

  ## Config

      config :money,
        default_currency: :USD

  ## Examples

      Money.new(123)
      %Money{amount: 123, currency: :USD}

  """
  def new(amount) do
    currency = Application.get_env(:money, :default_currency)

    if currency do
      new(amount, currency)
    else
      raise ArgumentError, "to use Money.new/1 you must set a default currency in your application config."
    end
  end

  @spec new(integer, atom | String.t()) :: t
  @doc """
  Create a new `Money` struct from currency sub-units (cents)

  ## Examples

      iex> Money.new(1_000_00, :USD)
      %Money{amount: 1_000_00, currency: :USD}

  """
  def new(int, currency) when is_integer(int),
    do: %Money{amount: int, currency: Currency.to_atom(currency)}

  @spec parse(String.t() | number | Decimal.t(), atom | String.t(), Keyword.t()) :: {:ok, t} | :error
  @doc ~S"""
  Parse a value into a `Money` type.

  The following options are available:

    * `:separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    * `:delimiter` - default `"."`, sets the decimal delimiter.
      "1.23"

  ## Examples

      iex> Money.parse("$1,234.56", :USD)
      {:ok, %Money{amount: 123456, currency: :USD}}

      iex> Money.parse("1.234,56", :EUR, separator: ".", delimiter: ",")
      {:ok, %Money{amount: 123456, currency: :EUR}}

      iex> Money.parse("1.234,56", :WRONG)
      :error

      iex> Money.parse(1_234.56, :USD)
      {:ok, %Money{amount: 123456, currency: :USD}}

      iex> Money.parse(1_234, :USD)
      {:ok, %Money{amount: 123400, currency: :USD}}

      iex> Money.parse(-1_234.56, :USD)
      {:ok, %Money{amount: -123456, currency: :USD}}

      iex> Money.parse(Decimal.from_float(1_234.56), :USD)
      {:ok, %Money{amount: 123456, currency: :USD}}

  """
  def parse(value, currency \\ nil, opts \\ [])

  def parse(value, nil, opts) do
    currency = Application.get_env(:money, :default_currency)

    if currency do
      parse(value, currency, opts)
    else
      raise ArgumentError, "to use Money.new/1 you must set a default currency in your application config."
    end
  end

  if Code.ensure_loaded?(Decimal) do
    @parser Decimal
  else
    @parser Float
  end

  def parse(str, currency, opts) when is_binary(str) do
    %ParseOptions{separator: _separator, delimiter: delimiter} = ParseOptions.get(opts)

    value =
      str
      |> prepare_parse_string(delimiter)
      |> add_missing_leading_digit

    case @parser.parse(value) do
      {float, _} -> parse(float, currency, [])
      :error -> :error
    end
  rescue
    _ -> :error
  end

  def parse(number, currency, _opts) when is_number(number) do
    {:ok, new(Kernel.round(number * Currency.sub_units_count!(currency)), currency)}
  end

  if Code.ensure_loaded?(Decimal) do
    def parse(%Decimal{} = decimal, currency, _opts) do
      {:ok,
       decimal
       |> Decimal.mult(Currency.sub_units_count!(currency))
       |> Decimal.round(0, Decimal.Context.get().rounding)
       |> Decimal.to_integer()
       |> new(currency)}
    end
  end

  defp prepare_parse_string(characters, delimiter, acc \\ [])

  defp prepare_parse_string([], _delimiter, acc),
    do: acc |> Enum.reverse() |> Enum.join()

  defp prepare_parse_string(["-" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["-" | acc])

  defp prepare_parse_string(["0" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["0" | acc])

  defp prepare_parse_string(["1" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["1" | acc])

  defp prepare_parse_string(["2" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["2" | acc])

  defp prepare_parse_string(["3" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["3" | acc])

  defp prepare_parse_string(["4" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["4" | acc])

  defp prepare_parse_string(["5" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["5" | acc])

  defp prepare_parse_string(["6" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["6" | acc])

  defp prepare_parse_string(["7" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["7" | acc])

  defp prepare_parse_string(["8" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["8" | acc])

  defp prepare_parse_string(["9" | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["9" | acc])

  defp prepare_parse_string([delimiter | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, ["." | acc])

  defp prepare_parse_string([_head | tail], delimiter, acc),
    do: prepare_parse_string(tail, delimiter, acc)

  defp prepare_parse_string(string, delimiter, _acc),
    do: prepare_parse_string(String.codepoints(string), delimiter)

  defp add_missing_leading_digit(<<"-.">> <> tail),
    do: "-0." <> tail

  defp add_missing_leading_digit(<<".">> <> tail),
    do: "0." <> tail

  defp add_missing_leading_digit(str), do: str

  @spec parse!(String.t() | number | Decimal.t(), atom | String.t(), Keyword.t()) :: t
  @doc ~S"""
  Parse a value into a `Money` type.
  Similar to `parse/3` but returns a `%Money{}` or raises an error if parsing fails.

  ## Examples

      iex> Money.parse!("1,234.56", :USD)
      %Money{amount: 123456, currency: :USD}

      iex> Money.parse!("wrong", :USD)
      ** (ArgumentError) unable to parse "wrong" with currency :USD

  """
  def parse!(value, currency \\ nil, opts \\ []) do
    case parse(value, currency, opts) do
      {:ok, money} -> money
      :error -> raise ArgumentError, "unable to parse #{inspect(value)} with currency #{inspect(currency)}"
    end
  end

  @spec compare(t, t) :: -1 | 0 | 1
  @doc ~S"""
  Compares two `Money` structs with each other.
  They must each be of the same currency and then their amounts are compared.
  If the first amount is larger than the second `1` is returned, if less than
  `-1` is returned, if both amounts are equal `0` is returned.

  See `cmp/2` for a similar function that returns `:lt`, `:eq` or `:gt` instead.

  ## Examples

      iex> Money.compare(Money.new(100, :USD), Money.new(100, :USD))
      0

      iex> Money.compare(Money.new(100, :USD), Money.new(101, :USD))
      -1

      iex> Money.compare(Money.new(101, :USD), Money.new(100, :USD))
      1

  """
  def compare(%Money{currency: cur} = a, %Money{currency: cur} = b) do
    case a.amount - b.amount do
      x when x > 0 -> 1
      x when x < 0 -> -1
      x when x == 0 -> 0
    end
  end

  def compare(%Money{} = a, %Money{} = b), do: fail_currencies_must_be_equal(a, b)

  @doc """
  Compares two `Money` structs with each other.
  They must each be of the same currency and then their amounts are compared.
  If the first amount is larger than the second `:gt` is returned, if less than
  `:lt` is returned, if both amounts are equal `:eq` is returned.

  See `compare/2` for a similar function that returns `-1`, `0` or `1` instead.

  ## Examples

      iex> Money.cmp(Money.new(100, :USD), Money.new(100, :USD))
      :eq

      iex> Money.cmp(Money.new(100, :USD), Money.new(101, :USD))
      :lt

      iex> Money.cmp(Money.new(101, :USD), Money.new(100, :USD))
      :gt

  """
  @spec cmp(t, t) :: :lt | :eq | :gt
  def cmp(a, b) do
    case compare(a, b) do
      x when x == -1 -> :lt
      x when x == 0 -> :eq
      x when x == 1 -> :gt
    end
  end

  @spec zero?(t) :: boolean
  @doc ~S"""
  Returns true if the amount of a `Money` struct is zero

  ## Examples

      iex> Money.zero?(Money.new(0, :USD))
      true

      iex> Money.zero?(Money.new(1, :USD))
      false

  """
  def zero?(%Money{amount: amount}) do
    amount == 0
  end

  @spec positive?(t) :: boolean
  @doc ~S"""
  Returns true if the amount of a `Money` is greater than zero

  ## Examples

      iex> Money.positive?(Money.new(0, :USD))
      false

      iex> Money.positive?(Money.new(1, :USD))
      true

      iex> Money.positive?(Money.new(-1, :USD))
      false

  """
  def positive?(%Money{amount: amount}) do
    amount > 0
  end

  @spec negative?(t) :: boolean
  @doc ~S"""
  Returns true if the amount of a `Money` is less than zero

  ## Examples

      iex> Money.negative?(Money.new(0, :USD))
      false

      iex> Money.negative?(Money.new(1, :USD))
      false

      iex> Money.negative?(Money.new(-1, :USD))
      true

  """
  def negative?(%Money{amount: amount}) do
    amount < 0
  end

  @spec equals?(t, t) :: boolean
  @doc ~S"""
  Returns true if two `Money` of the same currency have the same amount

  ## Examples

      iex> Money.equals?(Money.new(100, :USD), Money.new(100, :USD))
      true

      iex> Money.equals?(Money.new(101, :USD), Money.new(100, :USD))
      false

      iex> Money.equals?(Money.new(100, :USD), Money.new(100, :CAD))
      false

  """
  def equals?(%Money{amount: amount, currency: cur}, %Money{amount: amount, currency: cur}), do: true
  def equals?(%Money{}, %Money{}), do: false

  @spec neg(t) :: t
  @doc ~S"""
  Returns a `Money` with the amount negated.

  ## Examples

      iex> Money.new(100, :USD) |> Money.neg
      %Money{amount: -100, currency: :USD}

      iex> Money.new(-100, :USD) |> Money.neg
      %Money{amount: 100, currency: :USD}

  """
  def neg(%Money{amount: amount, currency: cur}),
    do: %Money{amount: -amount, currency: cur}

  @spec abs(t) :: t
  @doc ~S"""
  Returns a `Money` with the arithmetical absolute of the amount.

  ## Examples

      iex> Money.new(-100, :USD) |> Money.abs
      %Money{amount: 100, currency: :USD}

      iex> Money.new(100, :USD) |> Money.abs
      %Money{amount: 100, currency: :USD}

  """
  def abs(%Money{amount: amount, currency: cur}),
    do: %Money{amount: Kernel.abs(amount), currency: cur}

  @spec add(t, t | integer | float) :: t
  @doc ~S"""
  Adds two `Money` together or an integer (cents) amount to a `Money`

  ## Examples

      iex> Money.add(Money.new(100, :USD), Money.new(50, :USD))
      %Money{amount: 150, currency: :USD}

      iex> Money.add(Money.new(100, :USD), 50)
      %Money{amount: 150, currency: :USD}

      iex> Money.add(Money.new(100, :USD), 5.55)
      %Money{amount: 655, currency: :USD}

  """
  def add(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a + b, cur)

  def add(%Money{amount: amount, currency: cur}, addend) when is_integer(addend),
    do: Money.new(amount + addend, cur)

  def add(%Money{} = m, addend) when is_float(addend),
    do: add(m, Kernel.round(addend * 100))

  def add(%Money{} = a, %Money{} = b), do: fail_currencies_must_be_equal(a, b)

  @spec subtract(t, t | integer | float) :: t
  @doc ~S"""
  Subtracts one `Money` from another or an integer (cents) from a `Money`

  ## Examples

      iex> Money.subtract(Money.new(150, :USD), Money.new(50, :USD))
      %Money{amount: 100, currency: :USD}

      iex> Money.subtract(Money.new(150, :USD), 50)
      %Money{amount: 100, currency: :USD}

      iex> Money.subtract(Money.new(150, :USD), 1.25)
      %Money{amount: 25, currency: :USD}

  """
  def subtract(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a - b, cur)

  def subtract(%Money{amount: a, currency: cur}, subtractend) when is_integer(subtractend),
    do: Money.new(a - subtractend, cur)

  def subtract(%Money{} = m, subtractend) when is_float(subtractend),
    do: subtract(m, Kernel.round(subtractend * 100))

  def subtract(%Money{} = a, %Money{} = b), do: fail_currencies_must_be_equal(a, b)

  @spec multiply(t, integer | float | Decimal.t()) :: t
  @doc ~S"""
  Multiplies a `Money` by an amount

  ## Examples

      iex> Money.multiply(Money.new(100, :USD), 10)
      %Money{amount: 1000, currency: :USD}

      iex> Money.multiply(Money.new(100, :USD), 1.5)
      %Money{amount: 150, currency: :USD}

  """
  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_integer(multiplier),
    do: Money.new(amount * multiplier, cur)

  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_float(multiplier),
    do: Money.new(Kernel.round(amount * multiplier), cur)

  if Code.ensure_loaded?(Decimal) do
    def multiply(%Money{amount: amount, currency: cur}, %Decimal{} = multiplier),
      do:
        amount
        |> Decimal.mult(multiplier)
        |> Decimal.round(0, Decimal.Context.get().rounding)
        |> Decimal.to_integer()
        |> Money.new(cur)
  end

  @spec divide(t, integer) :: [t]
  @doc ~S"""
  Divides up `Money` by an amount

  ## Examples

      iex> Money.divide(Money.new(100, :USD), 2)
      [%Money{amount: 50, currency: :USD}, %Money{amount: 50, currency: :USD}]

      iex> Money.divide(Money.new(101, :USD), 2)
      [%Money{amount: 51, currency: :USD}, %Money{amount: 50, currency: :USD}]

  """
  def divide(%Money{amount: amount, currency: cur}, denominator) when is_integer(denominator) do
    value = div(amount, denominator)
    rem = rem(amount, denominator)
    do_divide(cur, value, rem, denominator, [])
  end

  defp do_divide(_currency, _value, _rem, 0, acc), do: acc |> Enum.reverse()

  defp do_divide(currency, value, 0, count, acc) do
    acc = [new(next_amount(value, 0, count), currency) | acc]
    count = decrement_abs(count)
    do_divide(currency, value, 0, count, acc)
  end

  defp do_divide(currency, value, rem, count, acc) do
    acc = [new(next_amount(value, rem, count), currency) | acc]
    rem = decrement_abs(rem)
    count = decrement_abs(count)
    do_divide(currency, value, rem, count, acc)
  end

  defp next_amount(0, -1, count) when count > 0, do: -1
  defp next_amount(value, 0, _count), do: value
  defp next_amount(value, _rem, _count), do: increment_abs(value)

  defp increment_abs(n) when n >= 0, do: n + 1
  defp increment_abs(n) when n < 0, do: n - 1
  defp decrement_abs(n) when n >= 0, do: n - 1
  defp decrement_abs(n) when n < 0, do: n + 1

  @spec to_string(t, Keyword.t()) :: String.t()
  @doc ~S"""
  Converts a `Money` struct to a string representation

  The following options are available:

    * `:separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    * `:delimiter` - default `"."`, sets the decimal delimiter.
      "1.23"
    * `:symbol` - default `true`, sets whether to display the currency symbol or not.
    * `:symbol_on_right` - default `false`, display the currency symbol on the right of the number, eg: 123.45€
    * `:symbol_space` - default `false`, add a space between currency symbol and number, eg: € 123,45 or 123.45 €
    * `:fractional_unit` - default `true`, show the remaining units after the delimiter
    * `:strip_insignificant_zeros` - default `false`, strip zeros after the delimiter
    * `:code` - default `false`, append the currency code after the number
    * `:minus_sign_first` - default `true`, display the minus sign before the currency symbol for negative values
    * `:strip_insignificant_fractional_unit` - default `false`, don't display the delimiter or fractional units if the fractional units are only insignificant zeros

  ## Examples

      iex> Money.to_string(Money.new(123456, :GBP))
      "£1,234.56"

      iex> Money.to_string(Money.new(123456, :EUR), separator: ".", delimiter: ",")
      "€1.234,56"

      iex> Money.to_string(Money.new(123456, :EUR), symbol: false)
      "1,234.56"

      iex> Money.to_string(Money.new(123456, :EUR), symbol: false, separator: "")
      "1234.56"

      iex> Money.to_string(Money.new(123456, :EUR), fractional_unit: false)
      "€1,234"

      iex> Money.to_string(Money.new(123450, :EUR), strip_insignificant_zeros: true)
      "€1,234.5"

      iex> Money.to_string(Money.new(123450, :EUR), code: true)
      "€1,234.50 EUR"

      iex> Money.to_string(Money.new(-123450, :EUR))
      "-€1,234.50"

      iex> Money.to_string(Money.new(-123450, :EUR), minus_sign_first: false)
      "€-1,234.50"

      iex> Money.to_string(Money.new(123400, :EUR), strip_insignificant_fractional_unit: true)
      "€1,234"

      iex> Money.to_string(Money.new(123450, :EUR), strip_insignificant_fractional_unit: true)
      "€1,234.50"

  It can also be interpolated (It implements the String.Chars protocol)
  To control the formatting, you can use the above options in your config,
  more information is in the introduction to `Money`

  ## Examples

      iex> "Total: #{Money.new(100_00, :USD)}"
      "Total: $100.00"

  """
  def to_string(%Money{} = money, opts \\ []) do
    %DisplayOptions{
      symbol: symbol,
      symbol_on_right: symbol_on_right,
      symbol_space: symbol_space,
      code: code,
      minus_sign_first: minus_sign_first
    } = opts = DisplayOptions.get(money, opts)

    number = format_number(money, opts)
    sign = if negative?(money), do: "-"
    space = if symbol_space, do: " "
    code = if code, do: " #{money.currency}"

    parts =
      cond do
        symbol_on_right ->
          [sign, number, space, symbol, code]

        negative?(money) and symbol == " " ->
          [sign, number, code]

        negative?(money) and minus_sign_first ->
          [sign, symbol, space, number, code]

        true ->
          [symbol, space, sign, number, code]
      end

    parts
    |> Enum.join()
    |> String.trim()
  end

  if Code.ensure_loaded?(Decimal) do
    @spec to_decimal(t) :: Decimal.t()
    @doc ~S"""
    Converts a `Money` struct to a `Decimal` representation

    ## Examples

        iex> Money.to_decimal(Money.new(123456, :GBP))
        Decimal.new("1234.56")

        iex> Money.to_decimal(Money.new(-123420, :EUR))
        Decimal.new("-1234.20")

    """
    def to_decimal(%Money{} = money) do
      sign = if money.amount >= 0, do: 1, else: -1
      coef = Money.abs(money).amount
      exp = -Money.Currency.exponent!(money)

      Decimal.new(sign, coef, exp)
    end

    @spec round(t, integer()) :: t
    @doc ~S"""
    Rounds a `Money` struct using a given number of places. `round` respects the
    rounding mode within the current Decimal context.

    By default `round` rounds to zero decimal places, using the currency's
    exponent. This results in rounding to whole values of the currency.
    Currencies without an exponent are not rounded unless a different value is
    passed for `places` other than the default.

    ## Examples

        iex> Money.round(Money.new(123456, :GBP))
        %Money{amount: 123500, currency: :GBP}

        iex> Money.round(Money.new(-123420, :EUR))
        %Money{amount: -123400, currency: :EUR}

        iex> Money.round(Money.new(-123420, :EUR), -3)
        %Money{amount: -100000, currency: :EUR}

        # Round to tenth of exponent
        iex> Money.round(Money.new(123425, :EUR), 1)
        %Money{amount: 123430, currency: :EUR}

        # Currencies round based on their exponent
        iex> Money.round(Money.new(820412, :JPY))
        %Money{amount: 820412, currency: :JPY}

        iex> Money.round(Money.new(820412, :JPY), -3)
        %Money{amount: 820000, currency: :JPY}

    """
    def round(%Money{} = money, places \\ 0) when is_integer(places) do
      {:ok, result} =
        money
        |> Money.to_decimal()
        |> Decimal.round(places, Decimal.Context.get().rounding)
        |> Money.parse(money.currency)

      result
    end
  end

  defp format_number(%Money{amount: amount} = money, %DisplayOptions{
         separator: separator,
         delimiter: delimiter,
         fractional_unit: fractional_unit,
         strip_insignificant_zeros: strip_insignificant_zeros,
         strip_insignificant_fractional_unit: strip_insignificant_fractional_unit
       }) do
    exponent = Currency.exponent(money)
    amount_abs = if amount < 0, do: -amount, else: amount
    amount_str = Integer.to_string(amount_abs)

    [sub_unit, super_unit] =
      amount_str
      |> String.pad_leading(exponent + 1, "0")
      |> String.reverse()
      |> String.split_at(exponent)
      |> Tuple.to_list()
      |> Enum.map(&String.reverse/1)

    super_unit = super_unit |> reverse_group(3) |> Enum.join(separator)

    sub_unit =
      sub_unit
      |> prepare_sub_unit(%{strip_insignificant_zeros: strip_insignificant_zeros})
      |> prepare_sub_unit(%{strip_insignificant_fractional_unit: strip_insignificant_fractional_unit})

    if fractional_unit and sub_unit != "" do
      [super_unit, sub_unit] |> Enum.join(delimiter)
    else
      super_unit
    end
  end

  defp prepare_sub_unit([value], options), do: prepare_sub_unit(value, options)
  defp prepare_sub_unit([], _), do: ""
  defp prepare_sub_unit(value, %{strip_insignificant_zeros: false}), do: value
  defp prepare_sub_unit(value, %{strip_insignificant_zeros: true}), do: Regex.replace(~r/0+$/, value, "")
  defp prepare_sub_unit(value, %{strip_insignificant_fractional_unit: false}), do: value

  defp prepare_sub_unit(value, %{strip_insignificant_fractional_unit: true}) do
    if Regex.match?(~r/[1-9]+/, value), do: value, else: ""
  end

  defp fail_currencies_must_be_equal(a, b) do
    raise ArgumentError,
      message: "Currency of #{inspect(a.currency)} must be the same as #{inspect(b.currency)}"
  end

  defp reverse_group(str, count) when is_binary(str) do
    reverse_group(str, Kernel.abs(count), [])
  end

  defp reverse_group("", _count, list) do
    list
  end

  defp reverse_group(str, count, list) do
    {first, last} = String.split_at(str, -count)
    reverse_group(first, count, [last | list])
  end

  defimpl String.Chars do
    def to_string(%Money{} = m) do
      Money.to_string(m)
    end
  end
end
