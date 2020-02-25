if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Type do
    @moduledoc """
    WARNING: this module is deprecated. Use Money.Ecto.Amount.Type module instead.
    Provides a type for Ecto usage.
    The underlying data type should be an integer.

    This type expects you to use a single currency.
    The currency must be defined in your configuration.

    config :money,
      default_currency: :GBP

    ## Migration Example

    create table(:my_table) do
      add :amount, :integer
    end

    ## Schema Example

    schema "my_table" do
      field :amount, Money.Ecto.Type
    end
    """

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type :: :integer
    @deprecated "Use Money.Ecto.Amount.Type.type/0 instead"
    def type, do: :integer

    @spec cast(String.t() | integer) :: {:ok, Money.t()}
    @deprecated "Use Money.Ecto.Amount.Type.cast/1 instead"
    def cast(val)

    def cast(str) when is_binary(str) do
      Money.parse(str)
    end

    def cast(int) when is_integer(int), do: {:ok, Money.new(int)}
    def cast(%Money{} = money), do: {:ok, money}
    def cast(%{"amount" => amount, "currency" => currency}), do: {:ok, Money.new(amount, currency)}
    def cast(%{"amount" => amount}), do: {:ok, Money.new(amount)}
    def cast(%{amount: amount, currency: currency}), do: {:ok, Money.new(amount, currency)}
    def cast(%{amount: amount}), do: {:ok, Money.new(amount)}
    def cast(_), do: :error

    @spec load(integer) :: {:ok, Money.t()}
    @deprecated "Use Money.Ecto.Amount.Type.load/1 instead"
    def load(int) when is_integer(int), do: {:ok, Money.new(int)}

    @spec dump(integer | Money.t()) :: {:ok, :integer}
    @deprecated "Use Money.Ecto.Amount.Type.dump/1 instead"
    def dump(int) when is_integer(int), do: {:ok, int}
    def dump(%Money{} = m), do: {:ok, m.amount}
    def dump(_), do: :error
  end
end
