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

  A helper function exists for each currency using the lowercase three-character currency code

  ## Example:

      iex> Money.Currency.usd(100)
      %Money{amount: 100, currency: :USD}
  """

  @currencies %{
    AED: %{name: "UAE Dirham",                                             symbol: " "},
    AFN: %{name: "Afghani",                                                symbol: "؋"},
    ALL: %{name: "Lek",                                                    symbol: "Lek"},
    AMD: %{name: "Armenian Dram",                                          symbol: " "},
    ANG: %{name: "Netherlands Antillian Guilder",                          symbol: "ƒ"},
    AOA: %{name: "Kwanza",                                                 symbol: " "},
    ARS: %{name: "Argentine Peso",                                         symbol: "$"},
    AUD: %{name: "Australian Dollar",                                      symbol: "$"},
    AWG: %{name: "Aruban Guilder",                                         symbol: "ƒ"},
    AZN: %{name: "Azerbaijanian Manat",                                    symbol: "ман"},
    BAM: %{name: "Convertible Marks",                                      symbol: "KM"},
    BBD: %{name: "Barbados Dollar",                                        symbol: "$"},
    BDT: %{name: "Taka",                                                   symbol: " "},
    BGN: %{name: "Bulgarian Lev",                                          symbol: "лв"},
    BHD: %{name: "Bahraini Dinar",                                         symbol: " "},
    BIF: %{name: "Burundi Franc",                                          symbol: " "},
    BMD: %{name: "Bermudian Dollar (customarily known as Bermuda Dollar)", symbol: "$"},
    BND: %{name: "Brunei Dollar",                                          symbol: "$"},
    BOB: %{name: "Boliviano Mvdol",                                        symbol: "$b"},
    BOV: %{name: "Boliviano Mvdol",                                        symbol: "$b"},
    BRL: %{name: "Brazilian Real",                                         symbol: "R$"},
    BSD: %{name: "Bahamian Dollar",                                        symbol: "$"},
    BTN: %{name: "Indian Rupee Ngultrum",                                  symbol: " "},
    BWP: %{name: "Pula",                                                   symbol: "P"},
    BYR: %{name: "Belarussian Ruble",                                      symbol: "p."},
    BZD: %{name: "Belize Dollar",                                          symbol: "BZ$"},
    CAD: %{name: "Canadian Dollar",                                        symbol: "$"},
    CDF: %{name: "Congolese Franc",                                        symbol: " "},
    CHF: %{name: "Swiss Franc",                                            symbol: "CHF"},
    CLF: %{name: "Chilean Peso Unidades de fomento",                       symbol: "$"},
    CLP: %{name: "Chilean Peso Unidades de fomento",                       symbol: "$"},
    CNY: %{name: "Yuan Renminbi",                                          symbol: "¥"},
    COP: %{name: "Colombian Peso Unidad de Valor Real",                    symbol: "$"},
    COU: %{name: "Colombian Peso Unidad de Valor Real",                    symbol: "$"},
    CRC: %{name: "Costa Rican Colon",                                      symbol: "₡"},
    CUC: %{name: "Cuban Peso Peso Convertible",                            symbol: "₱"},
    CUP: %{name: "Cuban Peso Peso Convertible",                            symbol: "₱"},
    CVE: %{name: "Cape Verde Escudo",                                      symbol: " "},
    CZK: %{name: "Czech Koruna",                                           symbol: "Kč"},
    DJF: %{name: "Djibouti Franc",                                         symbol: " "},
    DKK: %{name: "Danish Krone",                                           symbol: "kr"},
    DOP: %{name: "Dominican Peso",                                         symbol: "RD$"},
    DZD: %{name: "Algerian Dinar",                                         symbol: " "},
    EEK: %{name: "Kroon",                                                  symbol: " "},
    EGP: %{name: "Egyptian Pound",                                         symbol: "£"},
    ERN: %{name: "Nakfa",                                                  symbol: " "},
    ETB: %{name: "Ethiopian Birr",                                         symbol: " "},
    EUR: %{name: "Euro",                                                   symbol: "€"},
    FJD: %{name: "Fiji Dollar",                                            symbol: "$"},
    FKP: %{name: "Falkland Islands Pound",                                 symbol: "£"},
    GBP: %{name: "Pound Sterling",                                         symbol: "£"},
    GEL: %{name: "Lari",                                                   symbol: " "},
    GHS: %{name: "Cedi",                                                   symbol: " "},
    GIP: %{name: "Gibraltar Pound",                                        symbol: "£"},
    GMD: %{name: "Dalasi",                                                 symbol: " "},
    GNF: %{name: "Guinea Franc",                                           symbol: " "},
    GTQ: %{name: "Quetzal",                                                symbol: "Q"},
    GYD: %{name: "Guyana Dollar",                                          symbol: "$"},
    HKD: %{name: "Hong Kong Dollar",                                       symbol: "$"},
    HNL: %{name: "Lempira",                                                symbol: "L"},
    HRK: %{name: "Croatian Kuna",                                          symbol: "kn"},
    HTG: %{name: "Gourde US Dollar",                                       symbol: " "},
    HUF: %{name: "Forint",                                                 symbol: "Ft"},
    IDR: %{name: "Rupiah",                                                 symbol: "Rp"},
    ILS: %{name: "New Israeli Sheqel",                                     symbol: "₪"},
    INR: %{name: "Indian Rupee Ngultrum",                                  symbol: " "},
    INR: %{name: "Indian Rupee",                                           symbol: " "},
    IQD: %{name: "Iraqi Dinar",                                            symbol: " "},
    IRR: %{name: "Iranian Rial",                                           symbol: "﷼"},
    ISK: %{name: "Iceland Krona",                                          symbol: "kr"},
    JMD: %{name: "Jamaican Dollar",                                        symbol: "J$"},
    JOD: %{name: "Jordanian Dinar",                                        symbol: " "},
    JPY: %{name: "Yen",                                                    symbol: "¥"},
    KES: %{name: "Kenyan Shilling",                                        symbol: " "},
    KGS: %{name: "Som",                                                    symbol: "лв"},
    KHR: %{name: "Riel",                                                   symbol: "៛"},
    KMF: %{name: "Comoro Franc",                                           symbol: " "},
    KPW: %{name: "North Korean Won",                                       symbol: "₩"},
    KRW: %{name: "Won",                                                    symbol: "₩"},
    KWD: %{name: "Kuwaiti Dinar",                                          symbol: " "},
    KYD: %{name: "Cayman Islands Dollar",                                  symbol: "$"},
    KZT: %{name: "Tenge",                                                  symbol: "лв"},
    LAK: %{name: "Kip",                                                    symbol: "₭"},
    LBP: %{name: "Lebanese Pound",                                         symbol: "£"},
    LKR: %{name: "Sri Lanka Rupee",                                        symbol: "₨"},
    LRD: %{name: "Liberian Dollar",                                        symbol: "$"},
    LSL: %{name: "Rand Loti",                                              symbol: " "},
    LTL: %{name: "Lithuanian Litas",                                       symbol: "Lt"},
    LVL: %{name: "Latvian Lats",                                           symbol: "Ls"},
    LYD: %{name: "Libyan Dinar",                                           symbol: " "},
    MAD: %{name: "Moroccan Dirham",                                        symbol: " "},
    MDL: %{name: "Moldovan Leu",                                           symbol: " "},
    MGA: %{name: "Malagasy Ariary",                                        symbol: " "},
    MKD: %{name: "Denar",                                                  symbol: "ден"},
    MMK: %{name: "Kyat",                                                   symbol: " "},
    MNT: %{name: "Tugrik",                                                 symbol: "₮"},
    MOP: %{name: "Pataca",                                                 symbol: " "},
    MRO: %{name: "Ouguiya",                                                symbol: " "},
    MUR: %{name: "Mauritius Rupee",                                        symbol: "₨"},
    MVR: %{name: "Rufiyaa",                                                symbol: " "},
    MWK: %{name: "Kwacha",                                                 symbol: " "},
    MXN: %{name: "Mexican Peso Mexican Unidad de Inversion (UDI)",         symbol: "$"},
    MXV: %{name: "Mexican Peso Mexican Unidad de Inversion (UDI)",         symbol: "$"},
    MYR: %{name: "Malaysian Ringgit",                                      symbol: "RM"},
    MZN: %{name: "Metical",                                                symbol: "MT"},
    NAD: %{name: "Rand Namibia Dollar",                                    symbol: " "},
    NGN: %{name: "Naira",                                                  symbol: "₦"},
    NIO: %{name: "Cordoba Oro",                                            symbol: "C$"},
    NOK: %{name: "Norwegian Krone",                                        symbol: "kr"},
    NPR: %{name: "Nepalese Rupee",                                         symbol: "₨"},
    NZD: %{name: "New Zealand Dollar",                                     symbol: "$"},
    OMR: %{name: "Rial Omani",                                             symbol: "﷼"},
    PAB: %{name: "Balboa US Dollar",                                       symbol: "B/."},
    PEN: %{name: "Nuevo Sol",                                              symbol: "S/."},
    PGK: %{name: "Kina",                                                   symbol: " "},
    PHP: %{name: "Philippine Peso",                                        symbol: "Php"},
    PKR: %{name: "Pakistan Rupee",                                         symbol: "₨"},
    PLN: %{name: "Zloty",                                                  symbol: "zł"},
    PYG: %{name: "Guarani",                                                symbol: "Gs"},
    QAR: %{name: "Qatari Rial",                                            symbol: "﷼"},
    RON: %{name: "New Leu",                                                symbol: "lei"},
    RSD: %{name: "Serbian Dinar",                                          symbol: "Дин."},
    RUB: %{name: "Russian Ruble",                                          symbol: "руб"},
    RWF: %{name: "Rwanda Franc",                                           symbol: " "},
    SAR: %{name: "Saudi Riyal",                                            symbol: "﷼"},
    SBD: %{name: "Solomon Islands Dollar",                                 symbol: "$"},
    SCR: %{name: "Seychelles Rupee",                                       symbol: "₨"},
    SDG: %{name: "Sudanese Pound",                                         symbol: " "},
    SEK: %{name: "Swedish Krona",                                          symbol: "kr"},
    SGD: %{name: "Singapore Dollar",                                       symbol: "$"},
    SHP: %{name: "Saint Helena Pound",                                     symbol: "£"},
    SLL: %{name: "Leone",                                                  symbol: " "},
    SOS: %{name: "Somali Shilling",                                        symbol: "S"},
    SRD: %{name: "Surinam Dollar",                                         symbol: "$"},
    STD: %{name: "Dobra",                                                  symbol: " "},
    SVC: %{name: "El Salvador Colon US Dollar",                            symbol: "$"},
    SYP: %{name: "Syrian Pound",                                           symbol: "£"},
    SZL: %{name: "Lilangeni",                                              symbol: " "},
    THB: %{name: "Baht",                                                   symbol: "฿"},
    TJS: %{name: "Somoni",                                                 symbol: " "},
    TMT: %{name: "Manat",                                                  symbol: " "},
    TND: %{name: "Tunisian Dinar",                                         symbol: " "},
    TOP: %{name: "Pa'anga",                                                symbol: " "},
    TRY: %{name: "Turkish Lira",                                           symbol: "TL"},
    TTD: %{name: "Trinidad and Tobago Dollar",                             symbol: "TT$"},
    TWD: %{name: "New Taiwan Dollar",                                      symbol: "NT$"},
    TZS: %{name: "Tanzanian Shilling",                                     symbol: " "},
    UAH: %{name: "Hryvnia",                                                symbol: "₴"},
    UGX: %{name: "Uganda Shilling",                                        symbol: " "},
    USD: %{name: "US Dollar",                                              symbol: "$"},
    UYI: %{name: "Peso Uruguayo Uruguay Peso en Unidades Indexadas",       symbol: "$U"},
    UYU: %{name: "Peso Uruguayo Uruguay Peso en Unidades Indexadas",       symbol: "$U"},
    UZS: %{name: "Uzbekistan Sum",                                         symbol: "лв"},
    VEF: %{name: "Bolivar Fuerte",                                         symbol: "Bs"},
    VND: %{name: "Dong",                                                   symbol: "₫"},
    VUV: %{name: "Vatu",                                                   symbol: " "},
    WST: %{name: "Tala",                                                   symbol: " "},
    XAF: %{name: "CFA Franc BEAC",                                         symbol: " "},
    XAG: %{name: "Silver",                                                 symbol: " "},
    XAU: %{name: "Gold",                                                   symbol: " "},
    XBA: %{name: "Bond Markets Units European Composite Unit (EURCO)",     symbol: " "},
    XBB: %{name: "European Monetary Unit (E.M.U.-6)",                      symbol: " "},
    XBC: %{name: "European Unit of Account 9(E.U.A.-9)",                   symbol: " "},
    XBD: %{name: "European Unit of Account 17(E.U.A.-17)",                 symbol: " "},
    XCD: %{name: "East Caribbean Dollar",                                  symbol: "$"},
    XDR: %{name: "SDR",                                                    symbol: " "},
    XFU: %{name: "UIC-Franc",                                              symbol: " "},
    XOF: %{name: "CFA Franc BCEAO",                                        symbol: " "},
    XPD: %{name: "Palladium",                                              symbol: " "},
    XPF: %{name: "CFP Franc",                                              symbol: " "},
    XPT: %{name: "Platinum",                                               symbol: " "},
    XTS: %{name: "Codes specifically reserved for testing purposes",       symbol: " "},
    YER: %{name: "Yemeni Rial",                                            symbol: "﷼"},
    ZAR: %{name: "Rand",                                                   symbol: "R"},
    ZMK: %{name: "Zambian Kwacha",                                         symbol: " "},
    ZWL: %{name: "Zimbabwe Dollar",                                        symbol: " "}
  }

  @currencies |> Enum.each(fn ({cur, detail}) ->
    currency = to_string(cur) |> String.downcase
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

  @spec exists?(Money.t | String.t | atom) :: boolean
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
  def exists?(%Money{currency: currency}),
    do: exists?(currency)
  def exists?(currency),
    do: Map.has_key?(@currencies, convert_currency(currency))

  @spec get(Money.t | String.t | atom) :: map | nil
  @doc ~S"""
  Returns a map with the name and symbol of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.get(:USD)
      %{name: "US Dollar", symbol: "$"}
      iex> Money.Currency.get(:WRONG)
      nil
  """
  def get(%Money{currency: currency}),
    do: get(currency)
  def get(currency),
    do: @currencies[convert_currency(currency)]

  @spec get!(Money.t | String.t | atom) :: map
  @doc ~S"""
  Returns a map with the name and symbol of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.get!(:USD)
      %{name: "US Dollar", symbol: "$"}
      iex> Money.Currency.get!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  def get!(currency),
    do: get(currency) || currency_doesnt_exist_error(currency)

  @spec to_atom(Money.t | String.t | atom) :: atom
  @doc ~S"""
  Returns the atom representation of the currency key
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.to_atom("usd")
      :USD
      iex> Money.Currency.to_atom(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  def to_atom(%Money{currency: currency}),
    do: to_atom(currency)
  def to_atom(currency) do
    currency = convert_currency(currency)
    get!(currency)
    currency
  end

  @spec name(Money.t | String.t | atom) :: String.t
  @doc ~S"""
  Returns the name of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.name(:USD)
      "US Dollar"
      iex> Money.Currency.name(:WRONG)
      nil
  """
  def name(%Money{currency: currency}),
    do: name(currency)
  def name(currency),
    do: get(currency)[:name]

  @spec name!(Money.t | String.t | atom) :: String.t
  @doc ~S"""
  Returns the name of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.name!(:USD)
      "US Dollar"
      iex> Money.Currency.name!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  def name!(currency),
    do: name(currency) || currency_doesnt_exist_error(currency)

  @spec symbol(Money.t | String.t | atom) :: String.t
  @doc ~S"""
  Returns the symbol of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.symbol(:USD)
      "$"
      iex> Money.Currency.symbol(:WRONG)
      nil
  """
  def symbol(%Money{currency: currency}),
    do: symbol(currency)
  def symbol(currency),
    do: get(currency)[:symbol]

  @spec symbol!(Money.t | String.t | atom) :: String.t
  @doc ~S"""
  Returns the symbol of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.symbol!(:USD)
      "$"
      iex> Money.Currency.symbol!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  def symbol!(currency),
    do: symbol(currency) || currency_doesnt_exist_error(currency)

  defp convert_currency(currency) when is_binary(currency) do
    try do
      currency |> String.upcase |> String.to_existing_atom |> convert_currency
    rescue
      _ -> nil
    end
  end
  defp convert_currency(currency), do: currency

  defp currency_doesnt_exist_error(currency),
    do: raise ArgumentError, "currency #{currency} doesn’t exist"
end
