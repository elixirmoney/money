defmodule Money do
  import Kernel, except: [abs: 1]

  @moduledoc """
  Defines a `Money` struct along with convenience methods for working with currencies.

  ## Example:

      iex> money = Money.new(500, :USD)
      %Money{amount: 500, currency: :USD}
      iex> money = Money.add(money, 550)
      %Money{amount: 1050, currency: :USD}
      iex> Money.to_string(money)
      "$10.50"

  ## Configuration options

  You can set defaults in your Mix configuration to make working with `Money` a little easier.

  ## Configuration:

      config :money,
        default_currency: :EUR,           # this allows you to do Money.new(100)
        separator: ".",                   # change the default thousands separator for Money.to_string
        delimiter: ",",                   # change the default decimal delimeter for Money.to_string
        symbol: false                     # don’t display the currency symbol in Money.to_string
        symbol_on_right: false,           # position the symbol
        symbol_space: false               # add a space between symbol and number
        fractional_unit: true             # display units after the delimeter
        strip_insignificant_zeros: false  # don’t display the insignificant zeros or the delimeter
  """

  @type t :: %__MODULE__{
          amount: integer,
          currency: atom
        }

  defstruct amount: 0, currency: :USD

  alias Money.Currency

  @spec new(integer) :: t
  @doc ~S"""
  Create a new `Money` struct using a default currency.
  The default currency can be set in the system Mix config.

  ## Example Config:

      config :money,
        default_currency: :USD

  ## Example:

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

  ## Example:

      iex> Money.new(1_000_00, :USD)
      %Money{amount: 1_000_00, currency: :USD}
  """
  def new(int, currency) when is_integer(int),
    do: %Money{amount: int, currency: Currency.to_atom(currency)}

  @spec parse(String.t() | number | Decimal.t(), atom | String.t(), Keyword.t()) :: {:ok, t} | :error
  @doc ~S"""
  Parse a value into a `Money` type.

  The following options are available:

    - `separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    - `delimiter` - default `"."`, sets the decimal delimiter.
      "1.23"

  ## Examples:

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
      iex> Money.parse(Decimal.cast(1_234.56), :USD)
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

  def parse(str, currency, opts) when is_binary(str) do
    {_separator, delimiter} = get_parse_options(opts)

    value =
      str
      |> prepare_parse_string(delimiter)
      |> add_missing_leading_digit

    case Float.parse(value) do
      {float, _} -> parse(float, currency, [])
      :error -> :error
    end
  rescue
    _ -> :error
  end

  def parse(number, currency, _opts) when is_number(number) do
    {:ok, new(round(number * Currency.sub_units_count!(currency)), currency)}
  end

  if Code.ensure_loaded?(Decimal) do
    def parse(%Decimal{} = decimal, currency, _opts) do
      Decimal.to_float(decimal) |> Money.parse(currency)
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

  ## Example:

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

  ## Example:

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

  def compare(a, b), do: fail_currencies_must_be_equal(a, b)

  @doc """
  Compares two `Money` structs with each other.
  They must each be of the same currency and then their amounts are compared.
  If the first amount is larger than the second `:gt` is returned, if less than
  `:lt` is returned, if both amounts are equal `:eq` is returned.

  See `compare/2` for a similar function that returns `-1`, `0` or `1` instead.

  ## Example:

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

  ## Example:

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

  ## Example:

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

  ## Example:

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

  ## Example:

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

  ## Examples:

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

  ## Examples:

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

  ## Example:

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
    do: add(m, round(addend * 100))

  def add(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec subtract(t, t | integer | float) :: t
  @doc ~S"""
  Subtracts one `Money` from another or an integer (cents) from a `Money`

  ## Example:

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
    do: subtract(m, round(subtractend * 100))

  def subtract(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec multiply(t, integer | float) :: t
  @doc ~S"""
  Multiplies a `Money` by an amount

  ## Example:
      iex> Money.multiply(Money.new(100, :USD), 10)
      %Money{amount: 1000, currency: :USD}
      iex> Money.multiply(Money.new(100, :USD), 1.5)
      %Money{amount: 150, currency: :USD}
  """
  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_integer(multiplier),
    do: Money.new(amount * multiplier, cur)

  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_float(multiplier),
    do: Money.new(round(amount * multiplier), cur)

  @spec divide(t, integer) :: [t]
  @doc ~S"""
  Divides up `Money` by an amount

  ## Example:
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

    - `separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    - `delimiter` - default `"."`, sets the decimal delimiter.
      "1.23"
    - `symbol` - default `true`, sets whether to display the currency symbol or not.
    - `symbol_on_right` - default `false`, display the currency symbol on the right of the number, eg: 123.45€
    - `symbol_space` - default `false`, add a space between currency symbol and number, eg: € 123,45 or 123.45 €
    - `fractional_unit` - default `true`, show the remaining units after the delimeter
    - `strip_insignificant_zeros` - default `false`, strip zeros after the delimeter

  ## Example:

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

  It can also be interpolated (It implements the String.Chars protocol)
  To control the formatting, you can use the above options in your config,
  more information is in the introduction to `Money`

  ## Example:

      iex> "Total: #{Money.new(100_00, :USD)}"
      "Total: $100.00"
  """
  def to_string(%Money{} = money, opts \\ []) do
    {separator, delimeter, symbol, symbol_on_right, symbol_space, fractional_unit, strip_insignificant_zeros} =
      get_display_options(money, opts)

    number = format_number(money, separator, delimeter, fractional_unit, strip_insignificant_zeros, money)
    sign = if negative?(money), do: "-"
    space = if symbol_space, do: " "

    parts =
      if symbol_on_right do
        [sign, number, space, symbol]
      else
        [symbol, space, sign, number]
      end

    parts |> Enum.join() |> String.trim_leading()
  end

  if Code.ensure_loaded?(Decimal) do
    @spec to_decimal(t) :: Decimal.t()
    @doc ~S"""
    Converts a `Money` struct to a `Decimal` representation

    ## Example:

        iex> Money.to_decimal(Money.new(123456, :GBP))
        #Decimal<1234.56>
        iex> Money.to_decimal(Money.new(-123420, :EUR))
        #Decimal<-1234.2>
    """
    def to_decimal(%Money{} = money) do
      Decimal.from_float(money.amount / Money.Currency.sub_units_count!(money))
    end
  end

  defp format_number(%Money{amount: amount}, separator, delimeter, fractional_unit, strip_insignificant_zeros, money) do
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
    sub_unit = prepare_sub_unit(sub_unit, %{strip_insignificant_zeros: strip_insignificant_zeros})

    if fractional_unit && sub_unit != "" do
      [super_unit, sub_unit] |> Enum.join(delimeter)
    else
      super_unit
    end
  end

  defp prepare_sub_unit([value], options), do: prepare_sub_unit(value, options)
  defp prepare_sub_unit([], _), do: ""
  defp prepare_sub_unit(value, %{strip_insignificant_zeros: false}), do: value
  defp prepare_sub_unit(value, %{strip_insignificant_zeros: true}), do: Regex.replace(~r/0+$/, value, "")

  defp get_display_options(m, opts) do
    {separator, delimiter} = get_parse_options(opts)

    default_symbol = Application.get_env(:money, :symbol, true)
    default_symbol_on_right = Application.get_env(:money, :symbol_on_right, false)
    default_symbol_space = Application.get_env(:money, :symbol_space, false)
    default_fractional_unit = Application.get_env(:money, :fractional_unit, true)
    default_strip_insignificant_zeros = Application.get_env(:money, :strip_insignificant_zeros, false)

    symbol = if Keyword.get(opts, :symbol, default_symbol), do: Currency.symbol(m), else: ""
    symbol_on_right = Keyword.get(opts, :symbol_on_right, default_symbol_on_right)
    symbol_space = Keyword.get(opts, :symbol_space, default_symbol_space)
    fractional_unit = Keyword.get(opts, :fractional_unit, default_fractional_unit)
    strip_insignificant_zeros = Keyword.get(opts, :strip_insignificant_zeros, default_strip_insignificant_zeros)

    {separator, delimiter, symbol, symbol_on_right, symbol_space, fractional_unit, strip_insignificant_zeros}
  end

  defp get_parse_options(opts) do
    default_separator = Application.get_env(:money, :separator, ",")
    separator = Keyword.get(opts, :separator, default_separator)
    default_delimiter = Application.get_env(:money, :delimiter) || Application.get_env(:money, :delimeter, ".")
    delimiter = Keyword.get(opts, :delimiter) || Keyword.get(opts, :delimeter, default_delimiter)
    {separator, delimiter}
  end

  defp fail_currencies_must_be_equal(a, b) do
    raise ArgumentError, message: "Currency of #{a.currency} must be the same as #{b.currency}"
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
