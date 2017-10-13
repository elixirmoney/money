if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Type.Composite do
    @moduledoc """
    Implements support for the custom PostgreSQL composite type
    """

    @behaviour Ecto.Type

    def type do
      :money_with_currency
    end

    def load({amount, currency}) do
      {:ok, Money.new(amount, currency)}
    end

    def dump(%Money{} = money) do
      {:ok, {money.amount, to_string(money.currency)}}
    end

    def dump(_) do
      :error
    end

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

    def cast(_), do: :error
  end
end
