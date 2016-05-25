if Code.ensure_compiled?(Ecto.Type) do
  defmodule Money.Ecto.Type do
    @moduledoc """
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

    @behaviour Ecto.Type

    @spec type :: :integer
    def type, do: :integer

    @spec cast(String.t | integer) :: {:ok, Money.t}
    def cast(val)
    def cast(str) when is_binary(str) do
      value = str |> String.replace(",", "") |> String.replace(~r/.*?([\d]+(?:\.\d+)?)/, "\\1")
      case Float.parse(value) do
        {float, _} -> {:ok, Money.new(Kernel.round(float * 100))}
        :error -> :error
      end
    end
    def cast(int) when is_integer(int), do: {:ok, Money.new(int)}
    def cast(_), do: :error

    @spec load(integer) :: {:ok, Money.t}
    def load(int) when is_integer(int), do: {:ok, Money.new(int)}

    @spec dump(integer | Money.t) :: {:ok, :integer}
    def dump(int) when is_integer(int), do: {:ok, int}
    def dump(%Money{} = m), do: {:ok, m.amount}
    def dump(_), do: :error
  end
end
