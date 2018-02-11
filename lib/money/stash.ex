defmodule Money.Stash do
  def persist_rate({code, rate}) do
    find_or_create_table()
    |> :ets.insert({code, rate})
  end

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

  defp extract_rate([]), do: {nil, nil}
  defp extract_rate([{code, rate}]), do: {code, rate}
end
