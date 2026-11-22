if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Map.Type do
    @moduledoc """
    Provides a type for Ecto to store a multi-currency price.
    The underlying data type should be a map(JSON).
    Suitable for databases that do not support composite types, but support JSON (e.g. MySQL).

    ## Migration

        create table(:my_table) do
          add :price, :map
        end

    ## Schema

        schema "my_table" do
          field :price, Money.Ecto.Map.Type
        end

    """

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    defdelegate cast(money), to: Money.Ecto.Composite.Type

    @spec type() :: :map
    def type, do: :map

    def embed_as(_), do: :dump

    @spec dump(any()) :: :error | {:ok, %{String.t() => String.t() | integer()}}
    def dump(%Money{} = money) do
      {:ok, %{"amount" => money.amount, "currency" => to_string(money.currency)}}
    end

    def dump(_), do: :error

    @spec load(map()) :: {:ok, Money.t()} | :error
    def load(%{"amount" => amount, "currency" => currency}) when is_integer(amount) do
      {:ok, Money.new(amount, currency)}
    end

    def load(%{"amount" => amount, "currency" => currency}) when is_float(amount) and trunc(amount) == amount do
      {:ok, Money.new(trunc(amount), currency)}
    end

    def load(%{"amount" => amount, "currency" => currency}) when is_binary(amount) do
      case Integer.parse(amount) do
        {int, ""} -> {:ok, Money.new(int, currency)}
        _ -> :error
      end
    end

    def load(_), do: :error
  end
end
