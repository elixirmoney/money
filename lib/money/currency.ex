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
    AED: %{name: "UAE Dirham",                                             symbol: " ",    exponent: 2},
    AFN: %{name: "Afghani",                                                symbol: "؋",    exponent: 2},
    ALL: %{name: "Lek",                                                    symbol: "Lek",  exponent: 2},
    AMD: %{name: "Armenian Dram",                                          symbol: " ",    exponent: 2},
    ANG: %{name: "Netherlands Antillian Guilder",                          symbol: "ƒ",    exponent: 2},
    AOA: %{name: "Kwanza",                                                 symbol: " ",    exponent: 2},
    ARS: %{name: "Argentine Peso",                                         symbol: "$",    exponent: 2},
    AUD: %{name: "Australian Dollar",                                      symbol: "$",    exponent: 2},
    AWG: %{name: "Aruban Guilder",                                         symbol: "ƒ",    exponent: 2},
    AZN: %{name: "Azerbaijanian Manat",                                    symbol: "ман",  exponent: 2},
    BAM: %{name: "Convertible Marks",                                      symbol: "KM",   exponent: 2},
    BBD: %{name: "Barbados Dollar",                                        symbol: "$",    exponent: 2},
    BDT: %{name: "Taka",                                                   symbol: " ",    exponent: 2},
    BGN: %{name: "Bulgarian Lev",                                          symbol: "лв",   exponent: 2},
    BHD: %{name: "Bahraini Dinar",                                         symbol: " ",    exponent: 3},
    BIF: %{name: "Burundi Franc",                                          symbol: " ",    exponent: 0},
    BMD: %{name: "Bermudian Dollar (customarily known as Bermuda Dollar)", symbol: "$",    exponent: 2},
    BND: %{name: "Brunei Dollar",                                          symbol: "$",    exponent: 2},
    BOB: %{name: "Boliviano Mvdol",                                        symbol: "$b",   exponent: 2},
    BOV: %{name: "Boliviano Mvdol",                                        symbol: "$b",   exponent: 2},
    BRL: %{name: "Brazilian Real",                                         symbol: "R$",   exponent: 2},
    BSD: %{name: "Bahamian Dollar",                                        symbol: "$",    exponent: 2},
    BTN: %{name: "Indian Rupee Ngultrum",                                  symbol: " ",    exponent: 2},
    BWP: %{name: "Pula",                                                   symbol: "P",    exponent: 2},
    BYR: %{name: "Belarussian Ruble",                                      symbol: "p.",   exponent: 0},
    BZD: %{name: "Belize Dollar",                                          symbol: "BZ$",  exponent: 2},
    CAD: %{name: "Canadian Dollar",                                        symbol: "$",    exponent: 2},
    CDF: %{name: "Congolese Franc",                                        symbol: " ",    exponent: 2},
    CHF: %{name: "Swiss Franc",                                            symbol: "CHF",  exponent: 2},
    CLF: %{name: "Chilean Peso Unidades de fomento",                       symbol: "$",    exponent: 4},
    CLP: %{name: "Chilean Peso Unidades de fomento",                       symbol: "$",    exponent: 0},
    CNY: %{name: "Yuan Renminbi",                                          symbol: "¥",    exponent: 2},
    COP: %{name: "Colombian Peso Unidad de Valor Real",                    symbol: "$",    exponent: 2},
    COU: %{name: "Colombian Peso Unidad de Valor Real",                    symbol: "$",    exponent: 2},
    CRC: %{name: "Costa Rican Colon",                                      symbol: "₡",    exponent: 2},
    CUC: %{name: "Cuban Peso Peso Convertible",                            symbol: "₱",    exponent: 2},
    CUP: %{name: "Cuban Peso Peso Convertible",                            symbol: "₱",    exponent: 2},
    CVE: %{name: "Cape Verde Escudo",                                      symbol: " ",    exponent: 0},
    CZK: %{name: "Czech Koruna",                                           symbol: "Kč",   exponent: 2},
    DJF: %{name: "Djibouti Franc",                                         symbol: " ",    exponent: 0},
    DKK: %{name: "Danish Krone",                                           symbol: "kr",   exponent: 2},
    DOP: %{name: "Dominican Peso",                                         symbol: "RD$",  exponent: 2},
    DZD: %{name: "Algerian Dinar",                                         symbol: " ",    exponent: 2},
    EEK: %{name: "Kroon",                                                  symbol: " ",    exponent: 2},
    EGP: %{name: "Egyptian Pound",                                         symbol: "£",    exponent: 2},
    ERN: %{name: "Nakfa",                                                  symbol: " ",    exponent: 2},
    ETB: %{name: "Ethiopian Birr",                                         symbol: " ",    exponent: 2},
    EUR: %{name: "Euro",                                                   symbol: "€",    exponent: 2},
    FJD: %{name: "Fiji Dollar",                                            symbol: "$",    exponent: 2},
    FKP: %{name: "Falkland Islands Pound",                                 symbol: "£",    exponent: 2},
    GBP: %{name: "Pound Sterling",                                         symbol: "£",    exponent: 2},
    GEL: %{name: "Lari",                                                   symbol: " ",    exponent: 2},
    GHS: %{name: "Cedi",                                                   symbol: " ",    exponent: 2},
    GIP: %{name: "Gibraltar Pound",                                        symbol: "£",    exponent: 2},
    GMD: %{name: "Dalasi",                                                 symbol: " ",    exponent: 2},
    GNF: %{name: "Guinea Franc",                                           symbol: " ",    exponent: 0},
    GTQ: %{name: "Quetzal",                                                symbol: "Q",    exponent: 2},
    GYD: %{name: "Guyana Dollar",                                          symbol: "$",    exponent: 2},
    HKD: %{name: "Hong Kong Dollar",                                       symbol: "$",    exponent: 2},
    HNL: %{name: "Lempira",                                                symbol: "L",    exponent: 2},
    HRK: %{name: "Croatian Kuna",                                          symbol: "kn",   exponent: 2},
    HTG: %{name: "Gourde US Dollar",                                       symbol: " ",    exponent: 2},
    HUF: %{name: "Forint",                                                 symbol: "Ft",   exponent: 2},
    IDR: %{name: "Rupiah",                                                 symbol: "Rp",   exponent: 2},
    ILS: %{name: "New Israeli Sheqel",                                     symbol: "₪",    exponent: 2},
    INR: %{name: "Indian Rupee Ngultrum",                                  symbol: " ",    exponent: 2},
    INR: %{name: "Indian Rupee",                                           symbol: " ",    exponent: 2},
    IQD: %{name: "Iraqi Dinar",                                            symbol: " ",    exponent: 3},
    IRR: %{name: "Iranian Rial",                                           symbol: "﷼",    exponent: 2},
    ISK: %{name: "Iceland Krona",                                          symbol: "kr",   exponent: 0},
    JMD: %{name: "Jamaican Dollar",                                        symbol: "J$",   exponent: 2},
    JOD: %{name: "Jordanian Dinar",                                        symbol: " ",    exponent: 3},
    JPY: %{name: "Yen",                                                    symbol: "¥",    exponent: 0},
    KES: %{name: "Kenyan Shilling",                                        symbol: " ",    exponent: 2},
    KGS: %{name: "Som",                                                    symbol: "лв",   exponent: 2},
    KHR: %{name: "Riel",                                                   symbol: "៛",    exponent: 2},
    KMF: %{name: "Comoro Franc",                                           symbol: " ",    exponent: 0},
    KPW: %{name: "North Korean Won",                                       symbol: "₩",    exponent: 2},
    KRW: %{name: "Won",                                                    symbol: "₩",    exponent: 0},
    KWD: %{name: "Kuwaiti Dinar",                                          symbol: " ",    exponent: 3},
    KYD: %{name: "Cayman Islands Dollar",                                  symbol: "$",    exponent: 2},
    KZT: %{name: "Tenge",                                                  symbol: "лв",   exponent: 2},
    LAK: %{name: "Kip",                                                    symbol: "₭",    exponent: 2},
    LBP: %{name: "Lebanese Pound",                                         symbol: "£",    exponent: 2},
    LKR: %{name: "Sri Lanka Rupee",                                        symbol: "₨",    exponent: 2},
    LRD: %{name: "Liberian Dollar",                                        symbol: "$",    exponent: 2},
    LSL: %{name: "Rand Loti",                                              symbol: " ",    exponent: 2},
    LTL: %{name: "Lithuanian Litas",                                       symbol: "Lt",   exponent: 2},
    LVL: %{name: "Latvian Lats",                                           symbol: "Ls",   exponent: 2},
    LYD: %{name: "Libyan Dinar",                                           symbol: " ",    exponent: 3},
    MAD: %{name: "Moroccan Dirham",                                        symbol: " ",    exponent: 2},
    MDL: %{name: "Moldovan Leu",                                           symbol: " ",    exponent: 2},
    MGA: %{name: "Malagasy Ariary",                                        symbol: " ",    exponent: 2},
    MKD: %{name: "Denar",                                                  symbol: "ден",  exponent: 2},
    MMK: %{name: "Kyat",                                                   symbol: " ",    exponent: 2},
    MNT: %{name: "Tugrik",                                                 symbol: "₮",    exponent: 2},
    MOP: %{name: "Pataca",                                                 symbol: " ",    exponent: 2},
    MRO: %{name: "Ouguiya",                                                symbol: " ",    exponent: 2},
    MUR: %{name: "Mauritius Rupee",                                        symbol: "₨",    exponent: 2},
    MVR: %{name: "Rufiyaa",                                                symbol: " ",    exponent: 2},
    MWK: %{name: "Kwacha",                                                 symbol: " ",    exponent: 2},
    MXN: %{name: "Mexican Peso Mexican Unidad de Inversion (UDI)",         symbol: "$",    exponent: 2},
    MXV: %{name: "Mexican Peso Mexican Unidad de Inversion (UDI)",         symbol: "$",    exponent: 2},
    MYR: %{name: "Malaysian Ringgit",                                      symbol: "RM",   exponent: 2},
    MZN: %{name: "Metical",                                                symbol: "MT",   exponent: 2},
    NAD: %{name: "Rand Namibia Dollar",                                    symbol: " ",    exponent: 2},
    NGN: %{name: "Naira",                                                  symbol: "₦",    exponent: 2},
    NIO: %{name: "Cordoba Oro",                                            symbol: "C$",   exponent: 2},
    NOK: %{name: "Norwegian Krone",                                        symbol: "kr",   exponent: 2},
    NPR: %{name: "Nepalese Rupee",                                         symbol: "₨",    exponent: 2},
    NZD: %{name: "New Zealand Dollar",                                     symbol: "$",    exponent: 2},
    OMR: %{name: "Rial Omani",                                             symbol: "﷼",    exponent: 3},
    PAB: %{name: "Balboa US Dollar",                                       symbol: "B/.",  exponent: 2},
    PEN: %{name: "Nuevo Sol",                                              symbol: "S/.",  exponent: 2},
    PGK: %{name: "Kina",                                                   symbol: " ",    exponent: 2},
    PHP: %{name: "Philippine Peso",                                        symbol: "Php",  exponent: 2},
    PKR: %{name: "Pakistan Rupee",                                         symbol: "₨",    exponent: 2},
    PLN: %{name: "Zloty",                                                  symbol: "zł",   exponent: 2},
    PYG: %{name: "Guarani",                                                symbol: "Gs",   exponent: 0},
    QAR: %{name: "Qatari Rial",                                            symbol: "﷼",    exponent: 2},
    RON: %{name: "New Leu",                                                symbol: "lei",  exponent: 2},
    RSD: %{name: "Serbian Dinar",                                          symbol: "Дин.", exponent: 2},
    RUB: %{name: "Russian Ruble",                                          symbol: "руб",  exponent: 2},
    RWF: %{name: "Rwanda Franc",                                           symbol: " ",    exponent: 0},
    SAR: %{name: "Saudi Riyal",                                            symbol: "﷼",    exponent: 2},
    SBD: %{name: "Solomon Islands Dollar",                                 symbol: "$",    exponent: 2},
    SCR: %{name: "Seychelles Rupee",                                       symbol: "₨",    exponent: 2},
    SDG: %{name: "Sudanese Pound",                                         symbol: " ",    exponent: 2},
    SEK: %{name: "Swedish Krona",                                          symbol: "kr",   exponent: 2},
    SGD: %{name: "Singapore Dollar",                                       symbol: "$",    exponent: 2},
    SHP: %{name: "Saint Helena Pound",                                     symbol: "£",    exponent: 2},
    SLL: %{name: "Leone",                                                  symbol: " ",    exponent: 2},
    SOS: %{name: "Somali Shilling",                                        symbol: "S",    exponent: 2},
    SRD: %{name: "Surinam Dollar",                                         symbol: "$",    exponent: 2},
    STD: %{name: "Dobra",                                                  symbol: " ",    exponent: 2},
    SVC: %{name: "El Salvador Colon US Dollar",                            symbol: "$",    exponent: 2},
    SYP: %{name: "Syrian Pound",                                           symbol: "£",    exponent: 2},
    SZL: %{name: "Lilangeni",                                              symbol: " ",    exponent: 2},
    THB: %{name: "Baht",                                                   symbol: "฿",    exponent: 2},
    TJS: %{name: "Somoni",                                                 symbol: " ",    exponent: 2},
    TMT: %{name: "Manat",                                                  symbol: " ",    exponent: 2},
    TND: %{name: "Tunisian Dinar",                                         symbol: " ",    exponent: 2},
    TOP: %{name: "Pa'anga",                                                symbol: " ",    exponent: 2},
    TRY: %{name: "Turkish Lira",                                           symbol: "TL",   exponent: 2},
    TTD: %{name: "Trinidad and Tobago Dollar",                             symbol: "TT$",  exponent: 2},
    TWD: %{name: "New Taiwan Dollar",                                      symbol: "NT$",  exponent: 2},
    TZS: %{name: "Tanzanian Shilling",                                     symbol: " ",    exponent: 2},
    UAH: %{name: "Hryvnia",                                                symbol: "₴",    exponent: 2},
    UGX: %{name: "Uganda Shilling",                                        symbol: " ",    exponent: 0},
    USD: %{name: "US Dollar",                                              symbol: "$",    exponent: 2},
    UYI: %{name: "Peso Uruguayo Uruguay Peso en Unidades Indexadas",       symbol: "$U",   exponent: 0},
    UYU: %{name: "Peso Uruguayo Uruguay Peso en Unidades Indexadas",       symbol: "$U",   exponent: 2},
    UZS: %{name: "Uzbekistan Sum",                                         symbol: "лв",   exponent: 2},
    VEF: %{name: "Bolivar Fuerte",                                         symbol: "Bs",   exponent: 2},
    VND: %{name: "Dong",                                                   symbol: "₫",    exponent: 0},
    VUV: %{name: "Vatu",                                                   symbol: " ",    exponent: 0},
    WST: %{name: "Tala",                                                   symbol: " ",    exponent: 2},
    XAF: %{name: "CFA Franc BEAC",                                         symbol: " ",    exponent: 0},
    XAG: %{name: "Silver",                                                 symbol: " ",    exponent: 2},
    XAU: %{name: "Gold",                                                   symbol: " ",    exponent: 2},
    XBA: %{name: "Bond Markets Units European Composite Unit (EURCO)",     symbol: " ",    exponent: 2},
    XBB: %{name: "European Monetary Unit (E.M.U.-6)",                      symbol: " ",    exponent: 2},
    XBC: %{name: "European Unit of Account 9(E.U.A.-9)",                   symbol: " ",    exponent: 2},
    XBD: %{name: "European Unit of Account 17(E.U.A.-17)",                 symbol: " ",    exponent: 2},
    XCD: %{name: "East Caribbean Dollar",                                  symbol: "$",    exponent: 2},
    XDR: %{name: "SDR",                                                    symbol: " ",    exponent: 2},
    XFU: %{name: "UIC-Franc",                                              symbol: " ",    exponent: 2},
    XOF: %{name: "CFA Franc BCEAO",                                        symbol: " ",    exponent: 0},
    XPD: %{name: "Palladium",                                              symbol: " ",    exponent: 2},
    XPF: %{name: "CFP Franc",                                              symbol: " ",    exponent: 0},
    XPT: %{name: "Platinum",                                               symbol: " ",    exponent: 2},
    XTS: %{name: "Codes specifically reserved for testing purposes",       symbol: " ",    exponent: 2},
    YER: %{name: "Yemeni Rial",                                            symbol: "﷼",    exponent: 2},
    ZAR: %{name: "Rand",                                                   symbol: "R",    exponent: 2},
    ZMK: %{name: "Zambian Kwacha",                                         symbol: " ",    exponent: 2},
    ZWL: %{name: "Zimbabwe Dollar",                                        symbol: " ",    exponent: 2}
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
      %{name: "US Dollar", symbol: "$", exponent: 2}
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
      %{name: "US Dollar", symbol: "$", exponent: 2}
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

  @spec exponent(Money.t | String.t | atom) :: integer
  @doc ~S"""
  Returns the exponent of the currency or nil if it doesn’t exist.

  ## Example:

      iex> Money.Currency.exponent(:USD)
      2
      iex> Money.Currency.exponent(:WRONG)
      nil
  """
  def exponent(%Money{currency: currency}),
    do: exponent(currency)
  def exponent(currency),
    do: get(currency)[:exponent]

  @spec exponent!(Money.t | String.t | atom) :: integer
  @doc ~S"""
  Returns the exponent of the currency.
  An ArgumentError is raised if the currency doesn’t exist.

  ## Example:

      iex> Money.Currency.exponent!(:USD)
      2
      iex> Money.Currency.exponent!(:WRONG)
      ** (ArgumentError) currency WRONG doesn’t exist
  """
  def exponent!(currency),
    do: exponent(currency) || currency_doesnt_exist_error(currency)

  @spec sub_units_count!(Money.t | String.t | atom) :: integer
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
  def sub_units_count!(currency) do
    exponent = exponent!(currency)
    round(:math.pow(10, exponent))
  end

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
