defmodule Money.Currency.Rates.RussianCentrobank do
  def fetch_rates_data do
    "https://www.cbr.ru/DailyInfoWebServ/DailyInfo.asmx?WSDL"
    |> Soap.init_model(:url)
    |> make_request()
  end

  defp make_request({:ok, wsdl}) do
    operation = "GetCursOnDate"
    date = Date.utc_today()
    params = %{On_date: to_string(date)}

    wsdl
    |> Soap.call(operation, params)
    |> handle_response()
  end

  defp make_request({_status, _wsdl}), do: :error

  defp handle_response({:ok, %Soap.Response{body: body, headers: _, request_url: _, status_code: code}}) do
    body
    |> Soap.Response.parse(code)
    |> get_in([:GetCursOnDateResponse, :GetCursOnDateResult, :"diffgr:diffgram", :ValuteData])
    |> transform_result_data()
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
