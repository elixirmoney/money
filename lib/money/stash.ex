defmodule Money.Stash do
  @moduledoc """
  Provides an functions for fetch and persist data from ETS stash.
  """

  @doc ~S"""
  Persists a rate to ETS.

  ## Example:

      iex> Money.Stash.persist_rate({:RUB, %Money{amount: 100, currency: :RUB}})
      [true]
  """
  @spec persist_rate(tuple()) :: list()
  def persist_rate({code, rate}) do
    find_or_create_table()
    |> :ets.insert({code, rate})
  end

  def persist_updated_at_date do
    find_or_create_table()
    |> :ets.insert({:updated_at, Date.utc_today})
  end

  def fetch_updated_at_date do
    find_or_create_table()
    |> :ets.lookup(:updated_at)
    |> List.first
    |> elem(1)
  end

  @doc ~S"""
  Fething a rate from ETS by currency code.

  ## Example:

      iex> Money.fetch_rate(:EUR)
      %Money{amount: 7139, currency: :RUB}
  """
  @spec fetch_rate(atom()) :: Money.t()
  def fetch_rate(currency_code) do
    find_or_create_table()
    |> :ets.lookup(currency_code)
    |> extract_rate
  end

  defp find_or_create_table do
    :currency_rates
    |> :ets.info()
    |> process_ets_info_result()
  end

  defp process_ets_info_result(:undefined) do
    :ets.new(:currency_rates, [:set, :protected, :named_table])
  end

  defp process_ets_info_result(_info), do: :currency_rates

  defp extract_rate([]), do: nil
  defp extract_rate([{_, rate}]), do: rate
end
