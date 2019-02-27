if Code.ensure_compiled?(Ecto.Type) do
  defmodule Money.Currency.Ecto.Type do
    @moduledoc """
    Provides a type for Ecto to store a currency.
    The underlying data type is a string.

    ## Migration Example

        create table(:my_table) do
          add :currency, :string
        end

    ## Schema Example

        schema "my_table" do
          field :currency, Money.Currency.Ecto.Type
        end
    """

    alias Money.Currency

    @behaviour Ecto.Type

    @spec type :: :string
    def type, do: :string

    @spec cast(Money.t() | String.t()) :: {:ok, atom()}
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

    @spec dump(atom()) :: {:ok, String.t()}
    def dump(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}
    def dump(_), do: :error
  end
end
