defmodule Money.Currency.Rates do
  alias Money.Currency.Rates.{RussianCentrobank, EuropeanCentrobank}
  alias Money.{Currency, Stash}

  def fetch_rates(rates_resource \\ nil) do
    rates_resource
    |> validate_rates_resource()
    |> fetch_data_from_resource()
    |> Enum.map(&monefy_rate/1)
  end

  def persist_rates(rates_resource \\ nil) do
    rates_resource
    |> fetch_rates()
    |> persist_rates_data()
  end

  def add_rate(currency_code, rate, rate_currency) do
    currency_code
    |> validate_code()
    |> monefy_rate(rate, rate_currency)
    |> Stash.persist_rate()
  end

  def get_rate(currency), do: Stash.fetch_rate(currency)

  defp fetch_data_from_resource(:RuCB), do: RussianCentrobank.fetch_rates_data
  defp fetch_data_from_resource(:EuCB), do: EuropeanCentrobank.fetch_rates_data

  defp validate_rates_resource(nil), do: Application.fetch_env!(:money, :default_rates_resource)
  defp validate_rates_resource(resource), do: resource

  defp persist_rates_data([]), do: nil
  defp persist_rates_data(data) do
    for rate_data <- data, do: Stash.persist_rate(rate_data)
  end

  defp monefy_rate(currency_code, rate, rate_currency) do
    {currency_code, Money.parse!(rate, rate_currency)}
  end

  defp monefy_rate(%{currency_code: code, rate: rate, rate_currency: rate_currency}) do
    {code, Money.parse!(rate, rate_currency)}
  end

  defp validate_code(currency_code) do
    if Enum.member?(Currency.all, currency_code) do
      currency_code
    else
      raise ArgumentError, message: "You cant flush a rate with unsupported currency."
    end
  end
end
