if Code.ensure_compiled?(Ecto.Type) do
  defmodule Money.Ecto.MoneyzType do
    @moduledoc """
    Provides custom Ecto type to use `Money`.
    It might work with different adapters, but it has only been tested
    on PostgreSQL as a composite type.
    ## Usage:

    Schema:
        defmodule Item do
          use Ecto.Schema
          schema "items" do
            field :name, :string
            field :price, Money.Ecto.MoneyzType
          end
        end
    Migration:
        def change do
          execute "
          DO $$
            BEGIN
              IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_type WHERE typname = 'moneyz') THEN
                DROP DOMAIN IF EXISTS currency_loose_type;
                CREATE DOMAIN currency_loose_type AS TEXT CHECK ( VALUE ~ '^[A-Z]{2,3}$' );
                CREATE TYPE moneyz AS (
                  amount NUMERIC(precision,scale),
                  currency currency_loose_type
                );
            END IF;
          "
          create table(:items) do
            add :name, :string
            add :price, :moneyz
          end
        end
    """

    use Ecto.Type

    @spec type :: atom
    def type, do: :moneyz

    @spec cast(String.t | integer | {integer, String.t}) :: {:ok, Money.t}
    def cast(val)
    def cast(int) when is_integer(int), do: {:ok, Money.new(int)}
    def cast(str) when is_binary(str) do
      Money.parse(str)
    end
    def cast({amount, currency}) when is_integer(amount) do
      {:ok, Money.new(amount, currency)}
    end
    def cast({amount, currency}) when is_binary(amount) do
      Money.parse(amount, currency)
    end
    def cast(%{"amount" => amount, "currency" => currency}) when is_integer(amount) do
      {:ok, Money.new(amount, currency)}
    end
    def cast(%{"amount" => amount, "currency" => currency}) when is_binary(amount) do
      Money.parse(amount, currency)
    end
    def cast(%Money{}=money), do: {:ok, money}
    def cast(_), do: :error

    @spec load({%Decimal{}, String.t}) :: {:ok, Money.t}
    def load({amount, currency}) when is_binary(currency) do
      {:ok, Money.new(Decimal.to_integer(amount), currency)}
    end
    def load(_), do: :error

    @spec dump(integer | Money.t | {integer, String.t} | {integer, atom}) :: {integer, String.t}
    def dump(int) when is_integer(int), do: dump(Money.new(int))
    def dump(%Money{amount: amount, currency: currency}), do: dump({amount, currency})
    def dump({amount, currency}) when is_integer(amount) do
      {:ok, {amount, to_string(currency)}}
    end
    def dump(_), do: :error
  end
end
