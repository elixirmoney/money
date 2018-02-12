defmodule Money.Currency.Rates.CurrencyLayer do
  @moduledoc """
  Provides an functions for fetching currency rates from a currency layer api.
  """

  @doc ~S"""
  Returns the list of values associated with currency code, rate and rates currency.

  ## Example:

      iex> Money.Currency.Rates.CurrencyLayer.fetch_rates_data
      [%{currency_code: :USD, rate: "", rate_currency: :RUB}]
  """
  def fetch_rates_data do
    build_url()
    |> HTTPoison.get!()
    |> extract_body()
    |> process_currency_data()
  end

  defp build_url do
    "http://www.apilayer.net/api/live?access_key=#{fetch_api_key()}"
  end

  defp fetch_api_key, do: Application.fetch_env!(:money, :currency_layer_api_key)

  defp extract_body(%HTTPoison.Response{body: body, headers: _, request_url: _, status_code: 200}),
    do: JSX.decode!(body)

  defp process_currency_data(body) do
    case body["success"] do
      true ->
        data = Enum.map(body["quotes"], &transform_currency_data/1)
        {:ok, data}
      false ->
        error_message = body |> JSX.decode!() |> get_in(["error", "info"])
        {:error, error_message}
    end
  end

  defp transform_currency_data({currency, rate}) do
    to_currency = currency |> String.replace("USD", "") |> String.to_atom()

    %{currency_code: String.to_atom(currency), rate: to_string(rate), rate_currency: to_currency}
  end
end
