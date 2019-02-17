if Code.ensure_compiled?(Ecto.Type) do
  defmodule Money.Ecto.Amount.Type do
    @moduledoc """
    Provides a type for Ecto to store a amount.
    The underlying data type should be an integer.

    ## Migration Example

        create table(:my_table) do
          add :amount, :integer
        end

    ## Schema Example

        schema "my_table" do
          field :amount, Money.Ecto.Amount.Type
        end
    """

    @behaviour Ecto.Type

    @spec type :: :integer
    def type, do: :integer

    @spec cast(String.t | integer()) :: {:ok, Money.t}
    def cast(val)
    def cast(str) when is_binary(str) do
      Money.parse(str)
    end
    def cast(int) when is_integer(int), do: {:ok, Money.new(int)}
    def cast(%Money{} = money), do: {:ok, money}
    def cast(%{"amount" => amount, "currency" => currency}),
      do: {:ok, Money.new(amount, currency)}
    def cast(%{"amount" => amount}), do: {:ok, Money.new(amount)}
    def cast(_), do: :error

    @spec load(integer()) :: {:ok, Money.t}
    def load(int) when is_integer(int), do: {:ok, Money.new(int)}

    @spec dump(integer() | Money.t) :: {:ok, integer()}
    def dump(int) when is_integer(int), do: {:ok, int}
    def dump(%Money{} = m), do: {:ok, m.amount}
    def dump(_), do: :error
  end
end
