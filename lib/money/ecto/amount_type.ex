if Code.ensure_loaded?(Ecto.Type) do
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

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type :: :integer
    def type, do: :integer

    def embed_as(_), do: :dump

    @spec cast(String.t() | integer() | Money.t() | map() | any()) :: {:ok, Money.t()} | :error
    def cast(val)

    def cast(str) when is_binary(str) do
      Money.parse(str)
    end

    def cast(int) when is_integer(int), do: {:ok, Money.new(int)}

    def cast(%Money{currency: currency} = money) do
      case same_as_default_currency?(currency) do
        true -> {:ok, money}
        _ -> :error
      end
    end

    def cast(%{"amount" => amount, "currency" => currency}) do
      case same_as_default_currency?(currency) do
        true -> {:ok, Money.new(amount, currency)}
        _ -> :error
      end
    end

    def cast(%{"amount" => amount}), do: {:ok, Money.new(amount)}

    def cast(%{amount: amount, currency: currency}) do
      case same_as_default_currency?(currency) do
        true -> {:ok, Money.new(amount, currency)}
        _ -> :error
      end
    end

    def cast(%{amount: amount}), do: {:ok, Money.new(amount)}

    def cast(_), do: :error

    @spec load(integer()) :: {:ok, Money.t()}
    def load(int) when is_integer(int), do: {:ok, Money.new(int)}

    @spec dump(integer() | Money.t()) :: {:ok, integer()}
    def dump(int) when is_integer(int), do: {:ok, int}
    def dump(%Money{} = m), do: {:ok, m.amount}
    def dump(_), do: :error

    defp same_as_default_currency?(currency) do
      default_currency_string = Application.get_env(:money, :default_currency) |> to_string |> String.downcase()
      currency_string = currency |> to_string |> String.downcase()
      default_currency_string == currency_string
    end
  end
end
