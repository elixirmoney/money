defmodule Money.Currency.Rates.RussianCentralBank do
  @moduledoc """
  Provides an functions for fetching currency rates from a russian central bank.
  """

  @doc ~S"""
  Returns the list of values associated with currency code, rate and rates currency.

  ## Example:

      iex> Money.Currency.Rates.RussianCentralBank.fetch_rates_data
      [%{currency_code: :USD, rate: "60.1300", rate_currency: :RUB}]
  """
  @spec fetch_rates_data() :: list(map() | nil)
  def fetch_rates_data do
    "https://www.cbr.ru/DailyInfoWebServ/DailyInfo.asmx?WSDL"
    |> Soap.init_model(:url)
    |> make_request()
    |> handle_response()
    |> transform_result_data()
  end

  defp make_request({:ok, wsdl}) do
    operation = "GetCursOnDate"
    date = Date.utc_today()
    params = %{On_date: to_string(date)}

    Soap.call(wsdl, operation, params)
  end

  defp make_request({_status, _wsdl}), do: :error

  defp handle_response({:ok, %Soap.Response{body: body, headers: _, request_url: _, status_code: code}}) do
    body
    |> Soap.Response.parse(code)
    |> get_in([:GetCursOnDateResponse, :GetCursOnDateResult, :"diffgr:diffgram", :ValuteData])
  end

  defp transform_result_data(nil), do: []

  defp transform_result_data(data) do
    data
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&decorate_currency_rate(&1[:VchCode], &1[:Vcurs]))
    |> List.insert_at(0, decorate_currency_rate("RUB", "1.0000"))
  end

  defp decorate_currency_rate(currency, rate) do
    %{currency_code: String.to_atom(currency), rate: rate, rate_currency: :RUB}
  end
end
