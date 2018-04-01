defmodule Money.Currency do
  @moduledoc """
  Provides currency support to `Money`

  Some useful helper methods include:
  - `get/1`
  - `get!/1`
  - `exists?/1`
  - `to_atom/1`
  - `name/1`
  - `name!/1`
  - `symbol/1`
  - `symbol!/1`
  - `all/0`

  A helper function exists for each currency using the lowercase three-character currency code

  ## Example:

      iex> Money.Currency.usd(100)
      %Money{amount: 100, currency: :USD}
  """

  @currencies JSX.decode!(File.read!(Path.join(:code.priv_dir(:money), "currencies.json")), [{:labels, :atom}])

  @currencies |> Enum.each(fn ({cur, detail}) ->
    currency = cur |> to_string |> String.downcase
    @doc """
    Convenience method to create a `Money` object for the #{detail.name} (#{cur}) currency.

    ## Example:

        iex> Money.Currency.#{currency}(100)
        %Money{amount: 100, currency: :#{cur}}
    """
    def unquote(:"#{currency}")(amount) do
      Money.new(amount, unquote(cur))
    end
  end)

  alias Money.Currency.Rates

  @doc ~S"""
  Returns all the currencies

  ## Example:

      iex> Money.Currency.all |> Map.fetch!(:GBP)
      %{name: "Pound Sterling", symbol: "£", exponent: 2}

  """
  @spec all() :: map
  def all, do: @currencies

  @doc ~S"""
  Returns true if a currency is defined

  ## Example:

      iex> Money.Currency.exists?(:USD)
      true
      iex> Money.Currency.exists?("USD")
      true
      iex> Money.Currency.exists?(:WRONG)
      false
  """
  @spec exists?(Money.t | String.t | atom) :: boolean
  def exists?(%Money{currency: currency}),
    do: exists?(currency)
  def exists?(currency),
    do: Map.has_key?(@currencies, convert_currency(currency))

  @doc ~S"""
  Returns a map with the name and symbol of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.get(:USD)
      %{name: "US Dollar", symbol: "$", exponent: 2}
      iex> Money.Currency.get(:WRONG)
      nil
  """
  @spec get(Money.t | String.t | atom) :: map | nil
  def get(%Money{currency: currency}),
    do: get(currency)
  def get(currency),
    do: @currencies[convert_currency(currency)]

  @doc ~S"""
  Returns a map with the name and symbol of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.get!(:USD)
      %{name: "US Dollar", symbol: "$", exponent: 2}
      iex> Money.Currency.get!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  @spec get!(Money.t | String.t | atom) :: map
  def get!(currency),
    do: get(currency) || currency_doesnt_exist_error(currency)

  @doc ~S"""
  Returns the atom representation of the currency key
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.to_atom("usd")
      :USD
      iex> Money.Currency.to_atom(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  @spec to_atom(Money.t | String.t | atom) :: atom
  def to_atom(%Money{currency: currency}),
    do: to_atom(currency)
  def to_atom(currency) do
    currency = convert_currency(currency)
    get!(currency)
    currency
  end

  @doc ~S"""
  Returns the name of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.name(:USD)
      "US Dollar"
      iex> Money.Currency.name(:WRONG)
      nil
  """
  @spec name(Money.t | String.t | atom) :: String.t
  def name(%Money{currency: currency}),
    do: name(currency)
  def name(currency),
    do: get(currency)[:name]

  @doc ~S"""
  Returns the name of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.name!(:USD)
      "US Dollar"
      iex> Money.Currency.name!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  @spec name!(Money.t | String.t | atom) :: String.t
  def name!(currency),
    do: name(currency) || currency_doesnt_exist_error(currency)

  @doc ~S"""
  Returns the symbol of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.symbol(:USD)
      "$"
      iex> Money.Currency.symbol(:WRONG)
      nil
  """
  @spec symbol(Money.t | String.t | atom) :: String.t
  def symbol(%Money{currency: currency}),
    do: symbol(currency)
  def symbol(currency),
    do: get(currency)[:symbol]

  @doc ~S"""
  Returns the symbol of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.symbol!(:USD)
      "$"
      iex> Money.Currency.symbol!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  @spec symbol!(Money.t | String.t | atom) :: String.t
  def symbol!(currency),
    do: symbol(currency) || currency_doesnt_exist_error(currency)

  @doc ~S"""
  Returns the exponent of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.exponent(:USD)
      2
      iex> Money.Currency.exponent(:WRONG)
      nil
  """
  @spec exponent(Money.t | String.t | atom) :: integer
  def exponent(%Money{currency: currency}),
    do: exponent(currency)
  def exponent(currency),
    do: get(currency)[:exponent]

  @doc ~S"""
  Returns the exponent of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.exponent!(:USD)
      2
      iex> Money.Currency.exponent!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  @spec exponent!(Money.t | String.t | atom) :: integer
  def exponent!(currency),
    do: exponent(currency) || currency_doesnt_exist_error(currency)

  @doc ~S"""
  Returns the sub_units_count of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.sub_units_count!(:USD)
      100
      iex> Money.Currency.sub_units_count!(:JPY)
      1
      iex> Money.Currency.sub_units_count!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  @spec sub_units_count!(Money.t | String.t | atom) :: integer
  def sub_units_count!(currency) do
    exponent = exponent!(currency)
    round(:math.pow(10, exponent))
  end

  @spec persist_rates(atom() | nil) :: list(boolean())
  def persist_rates(rates_resource \\ nil), do: Rates.persist_rates(rates_resource)

  @spec get_rate(atom()) :: Money.t
  def get_rate(currency), do: Rates.get_rate(currency)

  def exchange(from_currency, from_amount, to_currency) do
    from_currency_amount = get_rate(from_currency).amount
    to_currency_amount = get_rate(to_currency).amount

    exchanged_amount = from_amount * to_currency_amount / from_currency_amount

    %Money{amount: exchanged_amount, currency: to_currency}
  end

  def exchange(%Money{amount: amount, currency: from_currency}, to_currency),
    do: exchange(from_currency, amount, to_currency)

  defp convert_currency(currency) when is_binary(currency) do
    currency |> String.upcase |> String.to_existing_atom |> convert_currency
  rescue
    _ -> nil
  end
  defp convert_currency(currency), do: currency

  defp currency_doesnt_exist_error(currency),
    do: raise ArgumentError, "currency #{currency} doesn’t exist"
end
