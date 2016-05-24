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
  """

  @type t :: %__MODULE__{
    amount: integer,
    currency: atom
  }

  defstruct amount: 0, currency: :USD

  alias Money.Currency

  @spec new(String.t | integer | t, atom) :: t

  @spec new(String.t | integer | t, atom | String.t) :: t
  @doc """
  Create a new money struct from currency sub-units (cents)

  ## Example:

      iex> Money.new(1_000_00, :USD)
      %Money{amount: 1_000_00, currency: :USD}
  """
  def new(int, currency) when is_integer(int) do
    %Money{amount: int, currency: Currency.to_atom(currency)}
  end
  def new(bitstr, currency) when is_bitstring(bitstr) do
    currency = Currency.to_atom(currency)
    case Integer.parse(bitstr) do
      :error -> raise ArgumentError
      {x, _} -> %Money{amount: x, currency: currency}
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

  @spec add(t, t | integer) :: t
  @doc ~S"""
  Adds two `Money` together or an integer (cents) amount to a `Money`


  ## Example:

      iex> Money.add(Money.new(100, :USD), Money.new(50, :USD))
      %Money{amount: 150, currency: :USD}
      iex> Money.add(Money.new(100, :USD), 50)
      %Money{amount: 150, currency: :USD}
  """
  def add(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a + b, cur)
  def add(%Money{amount: amount, currency: cur}, addend) when is_integer(addend),
    do: Money.new(amount + addend, cur)
  def add(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec subtract(t, t | integer) :: t
  @doc ~S"""
  Subtracts one `Money` from another or an integer (cents) from a `Money`

  ## Example:

      iex> Money.subtract(Money.new(150, :USD), Money.new(50, :USD))
      %Money{amount: 100, currency: :USD}
      iex> Money.subtract(Money.new(150, :USD), 50)
      %Money{amount: 100, currency: :USD}
  """
  def subtract(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a - b, cur)
  def subtract(%Money{amount: a, currency: cur}, subtractend) when is_integer(subtractend),
    do: Money.new(a - subtractend, cur)
  def subtract(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec multiply(t, t | integer) :: t
  @doc ~S"""
  Multiplies two `Money` together or a `Money` with an integer

  ## Example:
      iex> Money.multiply(Money.new(100, :USD), Money.new(10, :USD))
      %Money{amount: 1000, currency: :USD}
      iex> Money.multiply(Money.new(100, :USD), 10)
      %Money{amount: 1000, currency: :USD}
  """
  def multiply(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a * b, cur)
  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_integer(multiplier),
    do: Money.new(amount * multiplier, cur)
  def multiply(a, b), do: fail_currencies_must_be_equal(a, b)

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

  @spec to_string(t) :: String.t
  @doc ~S"""
  Converts a `Money` struct to a string representation

  ## Example:

      iex> Money.to_string(Money.new(123456, :GBP))
      "£1,234.56"
  """
  def to_string(%Money{} = m) do
    symbol = Currency.symbol(m)
    super_unit = div(m.amount, 100) |> Integer.to_string |> reverse_group(3) |> Enum.join(",")
    sub_unit = rem(abs(m.amount), 100) |> Integer.to_string |> String.rjust(2, ?0)
    number = [super_unit, sub_unit] |> Enum.join(".")
    [symbol, number] |> Enum.join |> String.lstrip
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
