defmodule Money do
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
        default_currency: :EUR,  # this allows you to do Money.new(100)
        separator: ".",          # change the default thousands separator for Money.to_string
        delimiter: ",",          # change the default decimal delimeter for Money.to_string
        symbol: false            # don’t display the currency symbol in Money.to_string
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

  @spec new(integer, atom | String.t) :: t
  @doc """
  Create a new `Money` struct from currency sub-units (cents)

  ## Example:

      iex> Money.new(1_000_00, :USD)
      %Money{amount: 1_000_00, currency: :USD}
  """
  def new(int, currency) when is_integer(int),
    do: %Money{amount: int, currency: Currency.to_atom(currency)}

  @spec parse(String.t | float, atom | String.t, Keyword.t) :: {:ok, t}
  @doc ~S"""
  Parse a value into a `Money` type.

  The following options are available:

    - `separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    - `delimeter` - default `"."`, sets the decimal delimeter.
      "1.23"

  ## Examples:

      iex> Money.parse("$1,234.56", :USD)
      {:ok, %Money{amount: 123456, currency: :USD}}
      iex> Money.parse("1.234,56", :EUR, separator: ".", delimeter: ",")
      {:ok, %Money{amount: 123456, currency: :EUR}}
      iex> Money.parse("1.234,56", :WRONG)
      :error
      iex> Money.parse(1_234.56, :USD)
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
    try do
      {separator, delimeter} = get_parse_options(opts)
      regex = Regex.compile!(".*?([\\d]+(?:[#{delimeter}]\\d+)?)")
      value = str
      |> String.replace(separator, "")
      |> String.replace(regex, "\\1")
      |> String.replace(delimeter, ".")
      case Float.parse(value) do
        {float, _} -> {:ok, new(round(float * 100), currency)}
        :error -> :error
      end
    rescue
      _ -> :error
    end
  end
  def parse(float, currency, _opts) when is_float(float) do
    {:ok, new(round(float * 100), currency)}
  end


  @spec parse(String.t | float, atom | String.t, Keyword.t) :: t
  @doc ~S"""
  Parse a value into a `Money` type.
  Similar to `parse/3` but returns a `%Money{}` or raises an error if parsing fails.

  ## Example:

      iex> Money.parse!("1,234.56", :USD)
      %Money{amount: 123456, currency: :USD}
      iex> Money.parse!("wrong", :USD)
      ** (ArgumentError) unable to parse "wrong"
  """
  def parse!(value, currency \\ nil, opts \\ []) do
    case parse(value, currency, opts) do
      {:ok, money} -> money
      :error -> raise ArgumentError, "unable to parse #{inspect(value)}"
    end
  end

  @spec compare(t, t) :: t
  @doc ~S"""
  Compares two `Money` structs with each other.
  They must each be of the same currency and then their amounts are compared

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
                    x when x >  0 -> 1
                    x when x <  0 -> -1
                    x when x == 0 -> 0
    end
  end
  def compare(a, b), do: fail_currencies_must_be_equal(a, b)

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
  """
  def equals?(%Money{amount: amount, currency: cur}, %Money{amount: amount, currency: cur}), do: true
  def equals?(%Money{currency: cur}, %Money{currency: cur}), do: false
  def equals?(a, b), do: fail_currencies_must_be_equal(a, b)

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

  @spec multiply(t, t | integer | float) :: t
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

  @spec divide(t, t | integer) :: t
  @doc ~S"""
  Divides one `Money` from another or a `Money` with an integer

  ## Example:
      iex> Money.divide(Money.new(100, :USD), Money.new(10, :USD))
      %Money{amount: 10, currency: :USD}
      iex> Money.divide(Money.new(100, :USD), 10)
      %Money{amount: 10, currency: :USD}
  """
  def divide(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(div(a, b), cur)
  def divide(%Money{amount: amount, currency: cur}, divisor) when is_integer(divisor),
    do: Money.new(div(amount, divisor), cur)
  def divide(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec to_string(t, Keyword.t) :: String.t
  @doc ~S"""
  Converts a `Money` struct to a string representation

  The following options are available:

    - `separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    - `delimeter` - default `"."`, sets the decimal delimeter.
      "1.23"
    - `symbol` = default `true`, sets whether to display the currency symbol or not.

  ## Example:

      iex> Money.to_string(Money.new(123456, :GBP))
      "£1,234.56"
      iex> Money.to_string(Money.new(123456, :EUR), separator: ".", delimeter: ",")
      "€1.234,56"
      iex> Money.to_string(Money.new(123456, :EUR), symbol: false)
      "1,234.56"
      iex> Money.to_string(Money.new(123456, :EUR), symbol: false, separator: "")
      "1234.56"

  It can also be interpolated (It implements the String.Chars protocol)
  To control the formatting, you can use the above options in your config,
  more information is in the introduction to `Money`

  ## Example:

      iex> "Total: #{Money.new(100_00, :USD)}"
      "Total: $100.00"
  """
  def to_string(%Money{} = m, opts \\ []) do
    {separator, delimeter, symbol} = get_display_options(m, opts)

    super_unit = div(m.amount, 100) |> Integer.to_string |> reverse_group(3) |> Enum.join(separator)
    sub_unit = rem(abs(m.amount), 100) |> Integer.to_string |> String.rjust(2, ?0)
    number = [super_unit, sub_unit] |> Enum.join(delimeter)
    [symbol, number] |> Enum.join |> String.lstrip
  end

  defp get_display_options(m, opts) do
    {separator, delimeter} = get_parse_options(opts)
    default_symbol = Application.get_env(:money, :symbol, true)
    symbol = if Keyword.get(opts, :symbol, default_symbol), do: Currency.symbol(m), else: ""
    {separator, delimeter, symbol}
  end

  defp get_parse_options(opts) do
    default_separator = Application.get_env(:money, :separator, ",")
    separator = Keyword.get(opts, :separator, default_separator)
    default_delimeter = Application.get_env(:money, :delimeter, ".")
    delimeter = Keyword.get(opts, :delimeter, default_delimeter)
    {separator, delimeter}
  end

  defp fail_currencies_must_be_equal(a, b) do
    raise ArgumentError, message: "Currency of #{a.currency} must be the same as #{b.currency}"
  end

  defp reverse_group(str, count) when is_binary(str) do
    reverse_group(str, abs(count), [])
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
