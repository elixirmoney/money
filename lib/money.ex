defmodule Money do

	@type t :: %__MODULE__{
    	amount: integer,
    	currency: atom
    }

	defstruct [amount: 0, currency: :USD]

	@spec new(integer, atom) :: t
	def new(%Money{} = num),
		do: num

	def new(int, currency) when is_integer(int) do
		cond do
			currency_exist?(currency) ->
				%Money{amount: int, currency: currency}
		end
  	end

  	def new(bitstr, currency) when is_bitstring(bitstr) do
		case Integer.parse(bitstr) do
			:error -> raise ArgumentError
			{x, _} -> %Money{amount: x, currency: currency}
		end
  	end

 	def currency_name(%Money{currency: cur1}) do
    	 currency_name(cur1)
    end

    def currency_name(currency) do
    	case currency_exist?(currency) do
      		true ->
      			get_currency(currency) |> Dict.get(:name)
     		_ -> nil
     	end
    end

 	def currency_symbol(%Money{currency: cur1}) do
    	 currency_symbol(cur1)
    end

    def currency_symbol(currency) do
    	case currency_exist?(currency) do
      		true ->
      			get_currency(currency) |> Dict.get(:symbol)
     		_ -> nil
     	end
    end

	def currency_all() do
		%{
			:AED => %{:name => "UAE Dirham", :symbol => " "},
			:AFN => %{:name => "Afghani", :symbol => "؋"},
			:ALL => %{:name => "Lek", :symbol => "Lek"},
			:AMD => %{:name => "Armenian Dram", :symbol => " "},
			:ANG => %{:name => "Netherlands Antillian Guilder", :symbol => "ƒ"},
			:AOA => %{:name => "Kwanza", :symbol => " "},
			:ARS => %{:name => "Argentine Peso", :symbol => "$"},
			:AUD => %{:name => "Australian Dollar", :symbol => "$"},
			:AWG => %{:name => "Aruban Guilder", :symbol => "ƒ"},
			:AZN => %{:name => "Azerbaijanian Manat", :symbol => "ман"},
			:BAM => %{:name => "Convertible Marks", :symbol => "KM"},
			:BBD => %{:name => "Barbados Dollar", :symbol => "$"},
			:BDT => %{:name => "Taka", :symbol => " "},
			:BGN => %{:name => "Bulgarian Lev", :symbol => "лв"},
			:BHD => %{:name => "Bahraini Dinar", :symbol => " "},
			:BIF => %{:name => "Burundi Franc", :symbol => " "},
			:BMD => %{:name => "Bermudian Dollar (customarily known as Bermuda Dollar)", :symbol => "$"},
			:BND => %{:name => "Brunei Dollar", :symbol => "$"},
			:BOB => %{:name => "Boliviano Mvdol", :symbol => "$b"},
			:BOV => %{:name => "Boliviano Mvdol", :symbol => "$b"},
			:BRL => %{:name => "Brazilian Real", :symbol => "R$"},
			:BSD => %{:name => "Bahamian Dollar", :symbol => "$"},
			:BWP => %{:name => "Pula", :symbol => "P"},
			:BYR => %{:name => "Belarussian Ruble", :symbol => "p."},
			:BZD => %{:name => "Belize Dollar", :symbol => "BZ$"},
			:CAD => %{:name => "Canadian Dollar", :symbol => "$"},
			:CDF => %{:name => "Congolese Franc", :symbol => " "},
			:CHF => %{:name => "Swiss Franc", :symbol => "CHF"},
			:CLF => %{:name => "Chilean Peso Unidades de fomento", :symbol => "$"},
			:CLP => %{:name => "Chilean Peso Unidades de fomento", :symbol => "$"},
			:CNY => %{:name => "Yuan Renminbi", :symbol => "¥"},
			:COP => %{:name => "Colombian Peso Unidad de Valor Real", :symbol => "$"},
			:COU => %{:name => "Colombian Peso Unidad de Valor Real", :symbol => "$"},
			:CRC => %{:name => "Costa Rican Colon", :symbol => "₡"},
			:CUP => %{:name => "Cuban Peso Peso Convertible", :symbol => "₱"},
			:CUC => %{:name => "Cuban Peso Peso Convertible", :symbol => "₱"},
			:CVE => %{:name => "Cape Verde Escudo", :symbol => " "},
			:CZK => %{:name => "Czech Koruna", :symbol => "Kč"},
			:DJF => %{:name => "Djibouti Franc", :symbol => " "},
			:DKK => %{:name => "Danish Krone", :symbol => "kr"},
			:DOP => %{:name => "Dominican Peso", :symbol => "RD$"},
			:DZD => %{:name => "Algerian Dinar", :symbol => " "},
			:EEK => %{:name => "Kroon", :symbol => " "},
			:EGP => %{:name => "Egyptian Pound", :symbol => "£"},
			:ERN => %{:name => "Nakfa", :symbol => " "},
			:ETB => %{:name => "Ethiopian Birr", :symbol => " "},
			:EUR => %{:name => "Euro", :symbol => "€"},
			:FJD => %{:name => "Fiji Dollar", :symbol => "$"},
			:FKP => %{:name => "Falkland Islands Pound", :symbol => "£"},
			:GBP => %{:name => "Pound Sterling", :symbol => "£"},
			:GEL => %{:name => "Lari", :symbol => " "},
			:GHS => %{:name => "Cedi", :symbol => " "},
			:GIP => %{:name => "Gibraltar Pound", :symbol => "£"},
			:GMD => %{:name => "Dalasi", :symbol => " "},
			:GNF => %{:name => "Guinea Franc", :symbol => " "},
			:GTQ => %{:name => "Quetzal", :symbol => "Q"},
			:GYD => %{:name => "Guyana Dollar", :symbol => "$"},
			:HKD => %{:name => "Hong Kong Dollar", :symbol => "$"},
			:HNL => %{:name => "Lempira", :symbol => "L"},
			:HRK => %{:name => "Croatian Kuna", :symbol => "kn"},
			:HTG => %{:name => "Gourde US Dollar", :symbol => " "},
			:HUF => %{:name => "Forint", :symbol => "Ft"},
			:IDR => %{:name => "Rupiah", :symbol => "Rp"},
			:ILS => %{:name => "New Israeli Sheqel", :symbol => "₪"},
			:INR => %{:name => "Indian Rupee", :symbol => " "},
			:INR => %{:name => "Indian Rupee Ngultrum", :symbol => " "},
			:BTN => %{:name => "Indian Rupee Ngultrum", :symbol => " "},
			:IQD => %{:name => "Iraqi Dinar", :symbol => " "},
			:IRR => %{:name => "Iranian Rial", :symbol => "﷼"},
			:ISK => %{:name => "Iceland Krona", :symbol => "kr"},
			:JMD => %{:name => "Jamaican Dollar", :symbol => "J$"},
			:JOD => %{:name => "Jordanian Dinar", :symbol => " "},
			:JPY => %{:name => "Yen", :symbol => "¥"},
			:KES => %{:name => "Kenyan Shilling", :symbol => " "},
			:KGS => %{:name => "Som", :symbol => "лв"},
			:KHR => %{:name => "Riel", :symbol => "៛"},
			:KMF => %{:name => "Comoro Franc", :symbol => " "},
			:KPW => %{:name => "North Korean Won", :symbol => "₩"},
			:KRW => %{:name => "Won", :symbol => "₩"},
			:KWD => %{:name => "Kuwaiti Dinar", :symbol => " "},
			:KYD => %{:name => "Cayman Islands Dollar", :symbol => "$"},
			:KZT => %{:name => "Tenge", :symbol => "лв"},
			:LAK => %{:name => "Kip", :symbol => "₭"},
			:LBP => %{:name => "Lebanese Pound", :symbol => "£"},
			:LKR => %{:name => "Sri Lanka Rupee", :symbol => "₨"},
			:LRD => %{:name => "Liberian Dollar", :symbol => "$"},
			:LTL => %{:name => "Lithuanian Litas", :symbol => "Lt"},
			:LVL => %{:name => "Latvian Lats", :symbol => "Ls"},
			:LYD => %{:name => "Libyan Dinar", :symbol => " "},
			:MAD => %{:name => "Moroccan Dirham", :symbol => " "},
			:MDL => %{:name => "Moldovan Leu", :symbol => " "},
			:MGA => %{:name => "Malagasy Ariary", :symbol => " "},
			:MKD => %{:name => "Denar", :symbol => "ден"},
			:MMK => %{:name => "Kyat", :symbol => " "},
			:MNT => %{:name => "Tugrik", :symbol => "₮"},
			:MOP => %{:name => "Pataca", :symbol => " "},
			:MRO => %{:name => "Ouguiya", :symbol => " "},
			:MUR => %{:name => "Mauritius Rupee", :symbol => "₨"},
			:MVR => %{:name => "Rufiyaa", :symbol => " "},
			:MWK => %{:name => "Kwacha", :symbol => " "},
			:MXN => %{:name => "Mexican Peso Mexican Unidad de Inversion (UDI)", :symbol => "$"},
			:MXV => %{:name => "Mexican Peso Mexican Unidad de Inversion (UDI)", :symbol => "$"},
			:MYR => %{:name => "Malaysian Ringgit", :symbol => "RM"},
			:MZN => %{:name => "Metical", :symbol => "MT"},
			:NGN => %{:name => "Naira", :symbol => "₦"},
			:NIO => %{:name => "Cordoba Oro", :symbol => "C$"},
			:NOK => %{:name => "Norwegian Krone", :symbol => "kr"},
			:NPR => %{:name => "Nepalese Rupee", :symbol => "₨"},
			:NZD => %{:name => "New Zealand Dollar", :symbol => "$"},
			:OMR => %{:name => "Rial Omani", :symbol => "﷼"},
			:PAB => %{:name => "Balboa US Dollar", :symbol => "B/."},
			:PEN => %{:name => "Nuevo Sol", :symbol => "S/."},
			:PGK => %{:name => "Kina", :symbol => " "},
			:PHP => %{:name => "Philippine Peso", :symbol => "Php"},
			:PKR => %{:name => "Pakistan Rupee", :symbol => "₨"},
			:PLN => %{:name => "Zloty", :symbol => "zł"},
			:PYG => %{:name => "Guarani", :symbol => "Gs"},
			:QAR => %{:name => "Qatari Rial", :symbol => "﷼"},
			:RON => %{:name => "New Leu", :symbol => "lei"},
			:RSD => %{:name => "Serbian Dinar", :symbol => "Дин."},
			:RUB => %{:name => "Russian Ruble", :symbol => "руб"},
			:RWF => %{:name => "Rwanda Franc", :symbol => " "},
			:SAR => %{:name => "Saudi Riyal", :symbol => "﷼"},
			:SBD => %{:name => "Solomon Islands Dollar", :symbol => "$"},
			:SCR => %{:name => "Seychelles Rupee", :symbol => "₨"},
			:SDG => %{:name => "Sudanese Pound", :symbol => " "},
			:SEK => %{:name => "Swedish Krona", :symbol => "kr"},
			:SGD => %{:name => "Singapore Dollar", :symbol => "$"},
			:SHP => %{:name => "Saint Helena Pound", :symbol => "£"},
			:SLL => %{:name => "Leone", :symbol => " "},
			:SOS => %{:name => "Somali Shilling", :symbol => "S"},
			:SRD => %{:name => "Surinam Dollar", :symbol => "$"},
			:STD => %{:name => "Dobra", :symbol => " "},
			:SVC => %{:name => "El Salvador Colon US Dollar", :symbol => "$"},
			:SYP => %{:name => "Syrian Pound", :symbol => "£"},
			:SZL => %{:name => "Lilangeni", :symbol => " "},
			:THB => %{:name => "Baht", :symbol => "฿"},
			:TJS => %{:name => "Somoni", :symbol => " "},
			:TMT => %{:name => "Manat", :symbol => " "},
			:TND => %{:name => "Tunisian Dinar", :symbol => " "},
			:TOP => %{:name => "Pa'anga", :symbol => " "},
			:TRY => %{:name => "Turkish Lira", :symbol => "TL"},
			:TTD => %{:name => "Trinidad and Tobago Dollar", :symbol => "TT$"},
			:TWD => %{:name => "New Taiwan Dollar", :symbol => "NT$"},
			:TZS => %{:name => "Tanzanian Shilling", :symbol => " "},
			:UAH => %{:name => "Hryvnia", :symbol => "₴"},
			:UGX => %{:name => "Uganda Shilling", :symbol => " "},
			:USD => %{:name => "US Dollar", :symbol => "$"},
			:UYU => %{:name => "Peso Uruguayo Uruguay Peso en Unidades Indexadas", :symbol => "$U"},
			:UYI => %{:name => "Peso Uruguayo Uruguay Peso en Unidades Indexadas", :symbol => "$U"},
			:UZS => %{:name => "Uzbekistan Sum", :symbol => "лв"},
			:VEF => %{:name => "Bolivar Fuerte", :symbol => "Bs"},
			:VND => %{:name => "Dong", :symbol => "₫"},
			:VUV => %{:name => "Vatu", :symbol => " "},
			:WST => %{:name => "Tala", :symbol => " "},
			:XAF => %{:name => "CFA Franc BEAC", :symbol => " "},
			:XAG => %{:name => "Silver", :symbol => " "},
			:XAU => %{:name => "Gold", :symbol => " "},
			:XBA => %{:name => "Bond Markets Units European Composite Unit (EURCO)", :symbol => " "},
			:XBB => %{:name => "European Monetary Unit (E.M.U.-6)", :symbol => " "},
			:XBC => %{:name => "European Unit of Account 9(E.U.A.-9)", :symbol => " "},
			:XBD => %{:name => "European Unit of Account 17(E.U.A.-17)", :symbol => " "},
			:XCD => %{:name => "East Caribbean Dollar", :symbol => "$"},
			:XDR => %{:name => "SDR", :symbol => " "},
			:XFU => %{:name => "UIC-Franc", :symbol => " "},
			:XOF => %{:name => "CFA Franc BCEAO", :symbol => " "},
			:XPD => %{:name => "Palladium", :symbol => " "},
			:XPF => %{:name => "CFP Franc", :symbol => " "},
			:XPT => %{:name => "Platinum", :symbol => " "},
			:XTS => %{:name => "Codes specifically reserved for testing purposes", :symbol => " "},
			:YER => %{:name => "Yemeni Rial", :symbol => "﷼"},
			:ZAR => %{:name => "Rand", :symbol => "R"},
			:ZAR => %{:name => "Rand Loti", :symbol => " "},
			:LSL => %{:name => "Rand Loti", :symbol => " "},
			:ZAR => %{:name => "Rand Namibia Dollar", :symbol => " "},
			:NAD => %{:name => "Rand Namibia Dollar", :symbol => " "},
			:ZMK => %{:name => "Zambian Kwacha", :symbol => " "},
			:ZWL => %{:name => "Zimbabwe Dollar", :symbol => " "}
		}
	end

	[:AED, :AFN, :ALL, :AMD, :ANG, :AOA, :ARS, :AUD, :AWG, :AZN, :BAM, :BBD, :BDT, :BGN, :BHD, :BIF, :BMD, :BND, :BOB, :BOV, :BRL, :BSD, :BWP, :BYR, :BZD, :CAD, :CDF, :CHF, :CLF, :CLP, :CNY, :COP, :COU, :CRC, :CUP, :CUC, :CVE, :CZK, :DJF, :DKK, :DOP, :DZD, :EEK, :EGP, :ERN, :ETB, :EUR, :FJD, :FKP, :GBP, :GEL, :GHS, :GIP, :GMD, :GNF, :GTQ, :GYD, :HKD, :HNL, :HRK, :HTG, :HUF, :IDR, :ILS, :INR, :INR, :BTN, :IQD, :IRR, :ISK, :JMD, :JOD, :JPY, :KES, :KGS, :KHR, :KMF, :KPW, :KRW, :KWD, :KYD, :KZT, :LAK, :LBP, :LKR, :LRD, :LTL, :LVL, :LYD, :MAD, :MDL, :MGA, :MKD, :MMK, :MNT, :MOP, :MRO, :MUR, :MVR, :MWK, :MXN, :MXV, :MYR, :MZN, :NGN, :NIO, :NOK, :NPR, :NZD, :OMR, :PAB, :PEN, :PGK, :PHP, :PKR, :PLN, :PYG, :QAR, :RON, :RSD, :RUB, :RWF, :SAR, :SBD, :SCR, :SDG, :SEK, :SGD, :SHP, :SLL, :SOS, :SRD, :STD, :SVC, :SYP, :SZL, :THB, :TJS, :TMT, :TND, :TOP, :TRY, :TTD, :TWD, :TZS, :UAH, :UGX, :USD, :UYU, :UYI, :UZS, :VEF, :VND, :VUV, :WST, :XAF, :XAG, :XAU, :XBA, :XBB, :XBC, :XBD, :XCD, :XDR, :XFU, :XOF, :XPD, :XPF, :XPT, :XTS, :YER, :ZAR, :ZAR, :LSL, :ZAR, :NAD, :ZMK, :ZWL] |> Enum.each fn name ->
		currency = to_string(name) |> String.Unicode.downcase
		def unquote(:"#{currency}")(amount) do
			 new(amount, unquote(name))
		end
	end


	defp currency_exist?(currency) do
		currency_all
		|> Dict.has_key?(currency)
	end

    def get_currency(currency) do
		currency_all
		|> Dict.get(currency)
	end

	@spec compare(t, t) :: t
	def compare(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
		case a.amount - b.amount do
			x when x>0 -> 1
			x when x<0 -> -1
			x when x==0 -> 0
		end
	end

	def compare(a, b) do
		raise fail_currencies_must_be_equal(a,b)
	end

	@spec zero?(t) :: boolean
	def zero?(a) do
		a.amount == 0
	end

	@spec positive?(t) :: boolean
	def positive?(a) do
		a.amount > 0
	end

	@spec negative?(t) :: boolean
	def negative?(a) do
		a.amount < 0
	end

	@spec equals?(t, t) :: boolean
	def equals?(a, b) do
		compare(a, b) == 0
	end

	@spec add(t, t|integer) :: t
	def add(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
		x = a.amount + b.amount
		Money.new(x, cur1)
	end

	def add(%Money{currency: cur1} = a, addend) when is_integer(addend) do
		x = a.amount + addend
		Money.new(x, cur1)
	end

	def add(a, b) do
		fail_currencies_must_be_equal(a, b)
	end

	@spec subtract(t, t|integer) :: t
	def subtract(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
		x = a.amount - b.amount
		Money.new(x, cur1)
	end

	def subtract(%Money{currency: cur1} = a, subtrahend) when is_integer(subtrahend) do
		x = a.amount - subtrahend
		Money.new(x, cur1)
	end

	def subtract(a, b) do
		fail_currencies_must_be_equal(a, b)
	end

	@spec multiply(t, t|integer) :: t
	def multiply(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
		x = a.amount * b.amount
		Money.new(x, cur1)
	end

	def multiply(%Money{currency: cur1} = a, multiplier) when is_integer(multiplier) do
		x = a.amount * multiplier
		Money.new(x, cur1)
	end

	def multiply(a, b) do
		fail_currencies_must_be_equal(a, b)
	end

	@spec divide(t, t|integer) :: t
	def divide(%Money{currency: cur1} = a, %Money{currency: cur1} = b) do
		x = round(a.amount / b.amount)
		Money.new(x, cur1)
	end

	def divide(%Money{currency: cur1} = a, divisor) when is_integer(divisor) do
		x = round(a.amount / divisor)
		Money.new(x, cur1)
	end

	def divide(a, b) do
		fail_currencies_must_be_equal(a, b)
	end

	@spec to_string(t) :: String.t
	def to_string(%Money{} = m) do
		decimal_amount = decimal_amount(m)
		symbol = currency_symbol(m)
		"#{symbol} #{decimal_amount}"
	end

	def decimal_amount(%Money{amount: money_amount} = money) do
		Float.round(money_amount/100 ,2)
	end

	defp fail_currencies_must_be_equal(a, b) do
		raise ArgumentError, message: "Currency of #{a.currency} must be the same as #{b.currency}"
	end
end
