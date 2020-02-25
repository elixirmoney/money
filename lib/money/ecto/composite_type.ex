if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Composite.Type do
    @moduledoc """
    Provides a type for Ecto to store a multi-currency price.
    The underlying data type should be an user-defined Postgres composite type `:money_with_currency`.

    ## Migration Example
        execute "CREATE TYPE public.money_with_currency AS (amount integer, currency char(3))"

        create table(:my_table) do
          add :price, :money_with_currency
        end

    ## Schema Example

        schema "my_table" do
          field :price, Money.Ecto.Composite.Type
        end
    """

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type() :: :money_with_currency
    def type, do: :money_with_currency

    @spec load({integer(), atom() | String.t()}) :: {:ok, Money.t()}
    def load({amount, currency}) do
      {:ok, Money.new(amount, currency)}
    end

    @spec dump(any()) :: :error | {:ok, {integer(), String.t()}}
    def dump(%Money{} = money), do: {:ok, {money.amount, to_string(money.currency)}}
    def dump(_), do: :error

    @spec cast(Money.t() | {integer(), String.t()} | map() | any()) :: :error | {:ok, Money.t()}
    def cast(%Money{} = money) do
      {:ok, money}
    end

    def cast({amount, currency}) when is_integer(amount) and (is_binary(currency) or is_atom(currency)) do
      {:ok, Money.new(amount, currency)}
    end

    def cast(%{"amount" => amount, "currency" => currency})
        when is_integer(amount) and (is_binary(currency) or is_atom(currency)) do
      {:ok, Money.new(amount, currency)}
    end

    def cast(%{amount: amount, currency: currency})
        when is_integer(amount) and (is_binary(currency) or is_atom(currency)) do
      {:ok, Money.new(amount, currency)}
    end

    def cast(_), do: :error
  end
end
