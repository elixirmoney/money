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
  def compare(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
    case a.amount - b.amount do
                    x when x >  0 -> 1
                    x when x <  0 -> -1
                    x when x == 0 -> 0
    end
  end

  def compare(a, b) do
    raise fail_currencies_must_be_equal(a,b)
  end

  @spec zero?(t) :: boolean
  def zero?(a) do
    a.amount == 0
  end

  @spec positive?(t) :: boolean
  def positive?(a) do
    a.amount > 0
  end

  @spec negative?(t) :: boolean
  def negative?(a) do
    a.amount < 0
  end

  @spec equals?(t, t) :: boolean
  def equals?(a, b) do
    compare(a, b) == 0
  end

  @spec add(t, t|integer) :: t
  def add(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
    x = a.amount + b.amount
    Money.new(x, cur1)
  end

  def add(%Money{currency: cur1} = a, addend) when is_integer(addend) do
    x = a.amount + addend
    Money.new(x, cur1)
  end

  def add(a, b) do
    fail_currencies_must_be_equal(a, b)
  end

  @spec subtract(t, t|integer) :: t
  def subtract(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
    x = a.amount - b.amount
    Money.new(x, cur1)
  end

  def subtract(%Money{currency: cur1} = a, subtrahend) when is_integer(subtrahend) do
    x = a.amount - subtrahend
    Money.new(x, cur1)
  end

  def subtract(a, b) do
    fail_currencies_must_be_equal(a, b)
  end

  @spec multiply(t, t|integer) :: t
  def multiply(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
    x = a.amount * b.amount
    Money.new(x, cur1)
  end

  def multiply(%Money{currency: cur1} = a, multiplier) when is_integer(multiplier) do
    x = a.amount * multiplier
    Money.new(x, cur1)
  end

  def multiply(a, b) do
    fail_currencies_must_be_equal(a, b)
  end

  @spec divide(t, t|integer) :: t
  def divide(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
    x = round(a.amount / b.amount)
    Money.new(x, cur1)
  end

  def divide(%Money{currency: cur1} = a, divisor) when is_integer(divisor) do
    x = round(a.amount / divisor)
    Money.new(x, cur1)
  end

  def divide(a, b) do
    fail_currencies_must_be_equal(a, b)
  end

  @spec to_string(t) :: String.t
  @doc ~S"""
  Converts a `Money` struct to a string representation

  ## Example:

      iex> Money.to_string(Money.new(123456, :GBP))
      "£1,234.56"

  Can also be used in string interpolation (Money implements the String.Chars protocol

  ## Example:

      iex> "Total: #{Money.new(5432, :USD)}"
      "Total: $54.32"
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
