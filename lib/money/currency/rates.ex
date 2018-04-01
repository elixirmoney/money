defmodule Money.Currency.Rates do
  @moduledoc """
  Provides a functions for fetching currency rates from external resources,
  persisting rates from it and add custom rates.
  """

  alias Money.Currency.Rates.{RussianCentralBank, CurrencyLayer}
  alias Money.{Currency, Stash}

  @doc ~S"""
  Returns the list of rates associated with currency codes.
  If rates_resource is not set then it will be use a configured default rates resource.

  ## Example:

      iex> Money.Currency.Rates.fetch_rates
      [{:RUB, %Money{amount: 100, currency: :RUB}}]
      iex> Money.Currency.Rates.fetch_rates(:currency_layer)
      [{:RUB, %Money{amount: 1, currency: :EUR}}]
  """
  @spec fetch_rates(atom() | nil) :: list()
  def fetch_rates(rates_resource \\ nil) do
    rates_resource
    |> validate_rates_resource()
    |> fetch_data_from_resource()
    |> process_fetch_result()
  end

  @doc ~S"""
  Fetches rates data from external resource and persist it to ETS stash.
  If rates_resource is not set then it will be use a configured default rates resource.
  Returns a results of persisting rates to ETS.

  ## Example:

      iex> Money.Currency.Rates.persist_rates
      [true, true, true]
      iex> Money.Currency.Rates.persist_rates(:currency_layer)
      [true, true, true]
  """
  @spec update_rates(atom() | nil) :: list(boolean())
  def update_rates(rates_resource \\ nil) do
    rates_resource
    |> fetch_rates()
    |> persist_rates_data()
  end

  @doc ~S"""
  Persisting a custom user rate to ETS. After it rate will be available to fetch.
  If code is not a member of available currencies list then raises an ArgumentError.

  ## Example:

      iex> Money.Currency.Rates.add_rate(:EUR, 1.23, :USD)
      [true]
      iex> Money.Currency.Rates.get_rate(:EUR)
      %Money{amount: 123, currency: :USD}
      iex> Money.Currency.Rates.add_rate(:FOO, 1.23, :USD)
      ** (ArgumentError) You cant persist a rate to unsupported currency.
  """
  @spec add_rate(atom(), String.t(), atom()) :: boolean()
  def add_rate(currency_code, rate, rate_currency) do
    currency_code
    |> validate_code()
    |> build_rate_map(rate, rate_currency)
    |> Stash.persist_rate()
  end

  @doc ~S"""
  Fetching persisted rate from an ETS stash.

  ## Example:

      iex> Money.Currency.Rates.get_rate(:EUR)
      %Money{amount: 123, currency: :USD}
  """
  @spec get_rate(atom()) :: Money.t()
  def get_rate(currency), do: Stash.fetch_rate(currency)

  def expired?, do: Stash.fetch_updated_at_date != Date.utc_today

  defp fetch_data_from_resource(:russian_cb), do: RussianCentralBank.fetch_rates_data
  defp fetch_data_from_resource(:currency_layer), do: CurrencyLayer.fetch_rates_data

  defp validate_rates_resource(nil), do: Application.fetch_env!(:money, :default_rates_resource)
  defp validate_rates_resource(resource), do: resource

  defp persist_rates_data({:ok, []}), do: nil
  defp persist_rates_data({:error, error_message}), do: {:error, error_message}

  defp persist_rates_data({:ok, data}) do
    Stash.drop_table()

    for rate_data <- data, do: Stash.persist_rate(rate_data)

    Stash.persist_updated_at_date()
  end

  defp build_rate_map(currency_code, rate, rate_currency) do
    {currency_code, %{amount: round_rate(rate), currency: rate_currency}}
  end
  defp build_rate_map(%{currency_code: currency_code, rate: rate, rate_currency: rate_currency}) do
    build_rate_map(currency_code, rate, rate_currency)
  end

  defp round_rate(rate) when is_float(rate), do: Float.round(rate, 6)
  defp round_rate(rate), do: rate

  defp validate_code(currency_code) do
    if Enum.member?(Currency.all, currency_code) do
      currency_code
    else
      raise ArgumentError, message: "You cant persist rate for an unsupported currency."
    end
  end

  defp process_fetch_result({:ok, data}), do: {:ok, Enum.map(data, &build_rate_map/1)}
  defp process_fetch_result({:error, error_message}), do: {:error, error_message}
end
