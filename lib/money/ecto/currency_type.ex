if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Currency.Type do
    @moduledoc """
    Provides a type for Ecto to store a currency.
    The underlying data type is a string.

    ## Migration

        create table(:my_table) do
          add :currency, :varchar, size: 3
        end

    ## Schema

        schema "my_table" do
          field :currency, Money.Ecto.Currency.Type
        end

    """

    alias Money.Currency

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type :: :string
    def type, do: :string

    @spec cast(Money.t() | String.t() | atom()) :: {:ok, atom()}
    def cast(val)

    def cast(%Money{currency: currency}), do: {:ok, currency}

    def cast(str) when is_binary(str) do
      {:ok, Currency.to_atom(str)}
    rescue
      _ -> :error
    end

    def cast(atom) when is_atom(atom) do
      if Currency.exists?(atom), do: {:ok, atom}, else: :error
    end

    def cast(_), do: :error

    @spec load(String.t()) :: {:ok, atom()}
    def load(str) when is_binary(str), do: {:ok, Currency.to_atom(str)}

    @spec dump(Money.t() | String.t() | atom()) :: {:ok, String.t()}
    def dump(val), do: with({:ok, atom} <- cast(val), do: {:ok, Atom.to_string(atom)})
  end
end
