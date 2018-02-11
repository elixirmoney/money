defmodule Money.Currency.Rates.EuropeanCentralBank do
  @moduledoc """
  Provides an functions for fetching currency rates from a european central bank.
  """

  import SweetXml

  @doc ~S"""
  Returns the list of values associated with currency code, rate and rates currency.

  ## Example:

      iex> Money.Currency.Rates.EuropeanCentralBank.fetch_rates_data
      [%{currency_code: :USD, rate: 0.81, rate_currency: :EUR}]
  """
  @spec fetch_rates_data() :: list(map() | nil)
  def fetch_rates_data do
    "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    |> HTTPoison.get!()
    |> extract_body()
    |> parse_body()
    |> transform_result_data()
  end

  defp extract_body(%HTTPoison.Response{body: body, request_url: _, status_code: _, headers: _}), do: body

  defp parse_body(body), do: xpath(body, ~x"//Cube/*"l, currency_code: ~x"@currency"S, rate: ~x"@rate"S)

  defp transform_result_data(response_result) do
    response_result
    |> Enum.reject(fn(x) -> x |> Map.values |> Enum.member?("") end)
    |> List.insert_at(0, %{currency_code: "EUR", rate: "1.0000"})
    |> Enum.map(&decorate_currency_rate/1)
  end

  defp decorate_currency_rate(%{currency_code: currency, rate: rate}) do
    %{currency_code: String.to_atom(currency), rate: recalculate_rate(rate), rate_currency: :EUR}
  end

  defp recalculate_rate(rate), do: 1.0 / String.to_float(rate)
end
