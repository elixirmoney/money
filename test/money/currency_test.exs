defmodule Money.CurrencyTest do
  use ExUnit.Case, async: true
  doctest Money.Currency

  alias Money.Currency

  test "exists?/1" do
    assert Currency.exists?(:USD)
    assert Currency.exists?(Currency.usd(100))
    refute Currency.exists?(:ABC)
  end

  test "get/1" do
    assert Currency.get(:USD) == %{name: "US Dollar", symbol: "$", exponent: 2, number: 840}
    assert Currency.get(Currency.usd(100)) == %{name: "US Dollar", symbol: "$", exponent: 2, number: 840}
    assert Currency.get(:ABC) == nil
  end

  test "get!/1" do
    assert Currency.get!(:USD) == %{name: "US Dollar", symbol: "$", exponent: 2, number: 840}
    assert Currency.get!(Currency.usd(100)) == %{name: "US Dollar", symbol: "$", exponent: 2, number: 840}
    assert_raise ArgumentError, fn -> Currency.get!(:ABC) end
  end

  test "name/1" do
    assert Currency.name(:USD) == "US Dollar"
    assert Currency.name(Currency.usd(100)) == "US Dollar"
    assert Currency.name(:ABC) == nil
  end

  test "name!/1" do
    assert Currency.name!(:USD) == "US Dollar"
    assert Currency.name!(Currency.usd(100)) == "US Dollar"
    assert_raise ArgumentError, fn -> Currency.name!(:ABC) end
  end

  test "symbol/1" do
    assert Currency.symbol(:USD) == "$"
    assert Currency.symbol(Currency.usd(100)) == "$"
    assert Currency.symbol(:ABC) == nil
  end

  test "symbol!/1" do
    assert Currency.symbol!(:USD) == "$"
    assert Currency.symbol!(Currency.usd(100)) == "$"
    assert_raise ArgumentError, fn -> Currency.symbol!(:ABC) end
  end

  test "exponent/1" do
    assert Currency.exponent(:USD) == 2
    assert Currency.exponent(:JPY) == 0
    assert Currency.exponent(:CLF) == 4
    assert Currency.exponent(:ABC) == nil
  end

  test "exponent!/1" do
    assert Currency.exponent(:USD) == 2
    assert Currency.exponent(:JPY) == 0
    assert Currency.exponent(:CLF) == 4
    assert_raise ArgumentError, fn -> Currency.exponent!(:ABC) end
  end

  test "exponents follow ISO 4217 minor units" do
    assert Currency.exponent!(:TND) == 3
    assert Currency.exponent!(:CVE) == 2

    assert Money.to_string(Money.new(1500, :TND)) == "د.ت1.500"
    assert Money.to_string(Money.new(150, :CVE)) == "$1.50"
    assert Money.parse!("1.5", :TND) == Money.new(1500, :TND)
    assert Money.parse!("1.5", :CVE) == Money.new(150, :CVE)
  end

  test "sub_units_count!/1" do
    assert Currency.sub_units_count!(:USD) == 100
    assert Currency.sub_units_count!(:JPY) == 1
    assert Currency.sub_units_count!(:CLF) == 10_000
    assert_raise ArgumentError, fn -> Currency.sub_units_count!(:ABC) end
  end

  test "number!/1" do
    assert Currency.number!(:USD) == 840
    assert Currency.number!(:JPY) == 392
    assert Currency.number!(:CLF) == 990
    assert_raise ArgumentError, fn -> Currency.number!(:ABC) end
  end

  test "current ISO 4217 codes" do
    for {code, number, exponent} <- [
          {:CHE, 947, 2},
          {:CHW, 948, 2},
          {:UYW, 927, 4},
          {:VED, 926, 2},
          {:XAD, 396, 2},
          {:ZWG, 924, 2}
        ] do
      assert Currency.exists?(code)
      assert Currency.number!(code) == number
      assert Currency.exponent!(code) == exponent
      assert Currency.to_atom(number) == code
    end

    assert Money.to_string(Money.new(1050, :ZWG)) == "ZiG10.50"
  end

  test "to_atom/1" do
    assert Currency.to_atom(:USD) == :USD
    assert Currency.to_atom("USD") == :USD
    assert Currency.to_atom("usd") == :USD
    assert Currency.to_atom(840) == :USD
    assert Currency.to_atom(Currency.usd(100)) == :USD
    assert_raise ArgumentError, fn -> Currency.to_atom(:ABC) end
    assert_raise ArgumentError, fn -> Currency.to_atom("ABC") end
    assert_raise ArgumentError, fn -> Currency.to_atom("abc") end
    assert_raise ArgumentError, fn -> Currency.to_atom("abc" <> "khgyujnk") end
  end

  describe "ISO numbers" do
    test "lookup by number returns the current currency" do
      assert Currency.to_atom(933) == :BYN
      assert Currency.to_atom(532) == :XCG
      assert Currency.number!(:BYR) == 933
      assert Currency.number!(:ANG) == 532
    end

    test "only replaced currencies share a number" do
      dups =
        Currency.all()
        |> Enum.group_by(fn {_, %{number: n}} -> n end, &elem(&1, 0))
        |> Enum.filter(fn {_, codes} -> length(codes) > 1 end)
        |> Enum.map(fn {n, codes} -> {n, Enum.sort(codes)} end)

      assert Enum.sort(dups) == [{532, [:ANG, :XCG]}, {933, [:BYN, :BYR]}]
    end
  end

  test "sub_units_count!/1 is exact for large exponents" do
    on_exit(fn -> Application.put_env(:money, :custom_currencies, []) end)

    Application.put_env(:money, :custom_currencies, ZZZ: %{name: "Z", symbol: "z", exponent: 24})

    assert Currency.sub_units_count!(:ZZZ) == 1_000_000_000_000_000_000_000_000
    assert Money.parse("1", :ZZZ) == {:ok, Money.new(1_000_000_000_000_000_000_000_000, :ZZZ)}
  end

  test "custom_currency" do
    on_exit(fn ->
      Application.put_env(:money, :custom_currencies, [])
    end)

    Application.put_env(:money, :custom_currencies, BTC: %{name: "Bitcoin", symbol: "₿", exponent: 2})

    assert Currency.exists?(:BTC)
    assert Currency.get(:BTC) == %{name: "Bitcoin", symbol: "₿", exponent: 2}
    assert Currency.get!(:BTC) == %{name: "Bitcoin", symbol: "₿", exponent: 2}
    assert Currency.name(:BTC) == "Bitcoin"
    assert Currency.name!(:BTC) == "Bitcoin"
    assert Currency.symbol(:BTC) == "₿"
    assert Currency.symbol!(:BTC) == "₿"
    assert Currency.exponent(:BTC) == 2
    assert Currency.exponent!(:BTC) == 2
    assert Currency.sub_units_count!(:BTC) == 100
    assert Currency.to_atom(:BTC) == :BTC
    assert %Money{amount: 1001, currency: :BTC} == Money.new(1001, :BTC)

    assert Currency.get(840) == %{name: "US Dollar", symbol: "$", exponent: 2, number: 840}
    assert Currency.to_atom(840) == :USD
    assert "₿10.01" == Money.to_string(Money.new(1001, :BTC))
  end
end
