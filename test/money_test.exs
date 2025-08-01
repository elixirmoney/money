defmodule MoneyTest do
  use ExUnit.Case, async: true
  doctest Money

  require Money.Currency
  import Money.Currency, only: [usd: 1, eur: 1, clf: 1, jpy: 1, omr: 1, xau: 1, zar: 1, ars: 1, pen: 1, brl: 1]

  test "new/1 with default currency set" do
    try do
      Application.put_env(:money, :default_currency, :GBP)
      assert Money.new(123) == Money.new(123, :GBP)
    after
      Application.delete_env(:money, :default_currency)
    end
  end

  test "new/1 with no config set" do
    assert_raise ArgumentError, fn ->
      Money.new(123)
    end
  end

  test "new/2 requires existing currency" do
    assert_raise ArgumentError, fn ->
      Money.new(123, :ABC)
    end
  end

  @tag decimal_1_2: true
  test "parse/3" do
    assert Money.parse("$1,000.00", :USD) == {:ok, usd(100_000)}
    assert Money.parse("$ 1,000.00", :USD) == {:ok, usd(100_000)}
    assert Money.parse("$ 1,000.0", :USD) == {:ok, usd(100_000)}
    assert Money.parse("$ 1000.0", :USD) == {:ok, usd(100_000)}
    assert Money.parse("1000.0", :USD) == {:ok, usd(100_000)}

    assert Money.parse("$-1,000.00", :USD) == {:ok, usd(-100_000)}
    assert Money.parse("$ -1,000.00", :USD) == {:ok, usd(-100_000)}
    assert Money.parse("$- 1,000.00", :USD) == {:ok, usd(-100_000)}
    assert Money.parse("-1000.0", :USD) == {:ok, usd(-100_000)}

    assert Money.parse(Decimal.from_float(-1000.0), :USD) == {:ok, usd(-100_000)}
    assert Money.parse(Decimal.from_float(4000.765), :USD) == {:ok, usd(4000_77)}

    Decimal.Context.with(%Decimal.Context{rounding: :floor}, fn ->
      assert Money.parse(Decimal.from_float(4000.765), :USD) == {:ok, usd(4000_76)}
    end)

    assert Money.parse(".25", :USD) == {:ok, usd(25)}
    assert Money.parse(",25", :EUR, separator: ".", delimiter: ",") == {:ok, eur(25)}
    assert Money.parse("-,25", :EUR, separator: ".", delimiter: ",") == {:ok, eur(-25)}

    assert Money.parse("0E+1", :USD) == {:ok, usd(0)}
    assert Money.parse("1000.0e1", :USD) == {:ok, usd(1_000_000)}
    assert Money.parse("1000.0E1", :USD) == {:ok, usd(1_000_000)}
    assert Money.parse("1000.0e+1", :USD) == {:ok, usd(1_000_000)}
    assert Money.parse("1000.0E+1", :USD) == {:ok, usd(1_000_000)}
    assert Money.parse("1000.0e-1", :USD) == {:ok, usd(10000)}
    assert Money.parse("1000.0E-1", :USD) == {:ok, usd(10000)}
    assert Money.parse("0.5e-1", :USD) == {:ok, usd(5)}

    assert Money.parse("1000.0", :WRONG) == :error
  end

  @tag decimal_1_2: true
  test "parse/1 big money" do
    assert Money.parse("$1,000,000,000,000,000.01", :USD) ==
             {:ok, usd(1_000_000_000_000_000_01)}

    assert Money.parse("$1,000,000,000,000,000,000.01", :USD) ==
             {:ok, usd(1_000_000_000_000_000_000_01)}

    assert Money.parse("$1,000,000,000,000,000,000,000.01", :USD) ==
             {:ok, usd(1_000_000_000_000_000_000_000_01)}
  end

  @tag decimal_1_2: true
  test "parse/3 with options" do
    assert Money.parse("€1.000,00", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("€ 1.000,00", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("$ 1.000,0", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("€ 1000,0", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("1000,0", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
  end

  @tag decimal_1_2: true
  test "parse/2 with default currency set" do
    try do
      Application.put_env(:money, :default_currency, :GBP)
      assert Money.parse("£1,234.56") == {:ok, Money.new(123_456, :GBP)}
    after
      Application.delete_env(:money, :default_currency)
    end
  end

  @tag decimal_1_2: true
  test "parse/2 with different exponents" do
    assert Money.parse(1_000.00, :EUR) == {:ok, eur(100_000)}
    assert Money.parse(1_000.00, :JPY) == {:ok, jpy(1000)}
    assert Money.parse(1_000.00, :OMR) == {:ok, omr(1_000_000)}
  end

  test "test factory USD" do
    assert Money.new(123, :USD) == usd(123)
  end

  test "test factory EUR" do
    assert Money.new(124, :EUR) == eur(124)
  end

  test "use string currency key" do
    assert Money.new(1000, "USD") == usd(1000)
    assert Money.new(1000, "usd") == usd(1000)
  end

  test "conversion error" do
    assert_raise FunctionClauseError, fn ->
      Money.new(:atom, :USD)
    end
  end

  test "test compare" do
    assert Money.compare(Money.new(123, :USD), Money.new(123, :USD)) == 0
    assert Money.compare(Money.new(121, :USD), Money.new(123, :USD)) == -1
    assert Money.compare(Money.new(124, :USD), Money.new(123, :USD)) == 1
  end

  test "comparing error" do
    assert_raise ArgumentError, fn ->
      Money.compare(Money.new(124, :EUR), Money.new(123, :USD))
    end
  end

  test "test cmp" do
    assert Money.cmp(Money.new(123, :USD), Money.new(123, :USD)) == :eq
    assert Money.cmp(Money.new(121, :USD), Money.new(123, :USD)) == :lt
    assert Money.cmp(Money.new(124, :USD), Money.new(123, :USD)) == :gt
  end

  test "cmp error" do
    assert_raise ArgumentError, fn ->
      Money.cmp(Money.new(124, :EUR), Money.new(123, :USD))
    end
  end

  test "test zero?" do
    assert Money.zero?(Money.new(0, :USD))
  end

  test "test equals?" do
    assert Money.equals?(Money.new(123, :USD), usd(123))
    refute Money.equals?(Money.new(123, :CAD), usd(123))
  end

  test "test negative?/1" do
    assert Money.negative?(Money.new(-123, :USD))
    refute Money.negative?(Money.new(123, :USD))
  end

  test "neg/1" do
    result = Money.neg(Money.new(-123, :USD))
    assert Money.equals?(result, Money.new(123, :USD))

    result = Money.neg(Money.new(123, :USD))
    assert Money.equals?(result, Money.new(-123, :USD))
  end

  test "abs/1" do
    result = Money.abs(Money.new(-123, :USD))
    assert Money.equals?(result, Money.new(123, :USD))

    result = Money.abs(Money.new(123, :USD))
    assert Money.equals?(result, Money.new(123, :USD))
  end

  test "test add" do
    assert Money.add(Money.new(100, :USD), Money.new(200, :USD)) == Money.new(300, :USD)
    assert Money.add(Money.new(100, :USD), 200) == Money.new(300, :USD)
    assert Money.add(Money.new(100, :USD), 3.333) == Money.new(433, :USD)
    assert Money.add(Money.new(100, :USD), 3.335) == Money.new(434, :USD)
  end

  test "add error" do
    assert_raise ArgumentError, fn ->
      Money.add(Money.new(124, :EUR), Money.new(123, :USD))
    end
  end

  test "test subtract" do
    assert Money.subtract(Money.new(200, :USD), Money.new(100, :USD)) == Money.new(100, :USD)
    assert Money.subtract(Money.new(200, :USD), 100) == Money.new(100, :USD)
    assert Money.subtract(Money.new(200, :USD), 0.5) == Money.new(150, :USD)
    assert Money.subtract(Money.new(200, :USD), 0.333) == Money.new(167, :USD)
    assert Money.subtract(Money.new(200, :USD), 0.335) == Money.new(166, :USD)
  end

  test "subtract error" do
    assert_raise ArgumentError, fn ->
      Money.subtract(Money.new(124, :EUR), Money.new(123, :USD))
    end
  end

  test "test multiply" do
    assert Money.multiply(Money.new(200, :USD), 100) == Money.new(20000, :USD)
    assert Money.multiply(Money.new(200, :USD), 1.5) == Money.new(300, :USD)
    assert Money.multiply(Money.new(200, :USD), 1.333) == Money.new(267, :USD)
    assert Money.multiply(Money.new(200, :USD), 1.335) == Money.new(267, :USD)
    assert Money.multiply(Money.new(200, :USD), Decimal.new("1.333")) == Money.new(267, :USD)
    assert Money.multiply(Money.new(200, :USD), Decimal.new("1.335")) == Money.new(267, :USD)

    Decimal.Context.with(%Decimal.Context{rounding: :floor}, fn ->
      assert Money.multiply(Money.new(200, :USD), Decimal.new("1.333")) == Money.new(266, :USD)
    end)
  end

  test "test divide" do
    assert Money.divide(Money.new(200, :USD), 2) == [
             usd(100),
             usd(100)
           ]

    assert Money.divide(Money.new(201, :USD), 2) == [
             usd(101),
             usd(100)
           ]

    assert Money.divide(Money.new(302, :USD), 3) == [
             usd(101),
             usd(101),
             usd(100)
           ]

    assert Money.divide(Money.new(100, :USD), 3) == [
             usd(34),
             usd(33),
             usd(33)
           ]

    assert Money.divide(Money.new(-7, :USD), 2) == [
             usd(-4),
             usd(-3)
           ]

    assert Money.divide(Money.new(-7, :USD), -2) == [
             usd(4),
             usd(3)
           ]

    assert Money.divide(Money.new(-1, :USD), 2) == [
             usd(-1),
             usd(0)
           ]

    assert Money.divide(Money.new(-1, :USD), -2) == [
             usd(1),
             usd(0)
           ]
  end

  test "test div" do
    # Basic division
    assert Money.div(Money.new(100, :USD), 2) == usd(50)
    assert Money.div(Money.new(200, :USD), 4) == usd(50)

    # Half-up rounding with positive numbers
    # 75.5 rounds up to 76
    assert Money.div(Money.new(151, :USD), 2) == usd(76)
    # 74.5 rounds up to 75
    assert Money.div(Money.new(149, :USD), 2) == usd(75)
    # 33.33... rounds to 33
    assert Money.div(Money.new(100, :USD), 3) == usd(33)
    # 33.66... rounds to 34
    assert Money.div(Money.new(101, :USD), 3) == usd(34)
    # 34.0 stays 34
    assert Money.div(Money.new(102, :USD), 3) == usd(34)
    # 34.33... rounds to 34
    assert Money.div(Money.new(103, :USD), 3) == usd(34)
    # 34.66... rounds to 35
    assert Money.div(Money.new(104, :USD), 3) == usd(35)
    # 35.0 stays 35
    assert Money.div(Money.new(105, :USD), 3) == usd(35)

    # Half-up rounding with negative numbers
    # -75.5 rounds to -76
    assert Money.div(Money.new(-151, :USD), 2) == usd(-76)
    # -74.5 rounds to -75
    assert Money.div(Money.new(-149, :USD), 2) == usd(-75)
    # -33.33... rounds to -33
    assert Money.div(Money.new(-100, :USD), 3) == usd(-33)
    # -33.66... rounds to -34
    assert Money.div(Money.new(-101, :USD), 3) == usd(-34)

    # Division by negative numbers
    assert Money.div(Money.new(151, :USD), -2) == usd(-76)
    assert Money.div(Money.new(-151, :USD), -2) == usd(76)

    # Division with float divisor
    assert Money.div(Money.new(100, :USD), 2.0) == usd(50)
    # 66.66... rounds to 67
    assert Money.div(Money.new(100, :USD), 1.5) == usd(67)
    # 40.0 stays 40
    assert Money.div(Money.new(100, :USD), 2.5) == usd(40)

    # Edge cases
    # 0.5 rounds up to 1
    assert Money.div(Money.new(1, :USD), 2) == usd(1)
    # -0.5 rounds to -1
    assert Money.div(Money.new(-1, :USD), 2) == usd(-1)
    # 0 divided by anything is 0
    assert Money.div(Money.new(0, :USD), 5) == usd(0)

    # Division with Decimal divisor
    assert Money.div(Money.new(100, :USD), Decimal.new("2")) == usd(50)
    assert Money.div(Money.new(100, :USD), Decimal.new("2.0")) == usd(50)
    # 66.66... rounds to 67 with half-up
    assert Money.div(Money.new(100, :USD), Decimal.new("1.5")) == usd(67)
    # 40.0 stays 40
    assert Money.div(Money.new(100, :USD), Decimal.new("2.5")) == usd(40)
    # Half-up rounding: 75.5 rounds up to 76
    assert Money.div(Money.new(151, :USD), Decimal.new("2")) == usd(76)
    # 33.33... rounds to 33
    assert Money.div(Money.new(100, :USD), Decimal.new("3")) == usd(33)
    # Negative numbers with Decimal
    assert Money.div(Money.new(-151, :USD), Decimal.new("2")) == usd(-76)
    assert Money.div(Money.new(151, :USD), Decimal.new("-2")) == usd(-76)

    # Division by zero should raise ArithmeticError
    assert_raise ArithmeticError, "division by zero", fn ->
      Money.div(Money.new(100, :USD), 0)
    end

    assert_raise ArithmeticError, "division by zero", fn ->
      Money.div(Money.new(100, :USD), 0.0)
    end

    assert_raise ArithmeticError, "division by zero", fn ->
      Money.div(Money.new(100, :USD), Decimal.new("0"))
    end

    assert_raise ArithmeticError, "division by zero", fn ->
      Money.div(Money.new(100, :USD), Decimal.new("0.0"))
    end
  end

  test "test divide error cases" do
    # Division by zero should raise ArithmeticError
    assert_raise ArithmeticError, "division by zero", fn ->
      Money.divide(Money.new(100, :USD), 0)
    end
  end

  test "test to_string" do
    assert Money.to_string(usd(500)) == "$5.00"
    assert Money.to_string(eur(1234)) == "€12.34"
    assert Money.to_string(xau(20305)) == "203.05"
    assert Money.to_string(zar(1_234_567_890)) == "R12,345,678.90"
  end

  test "to_string with negative values" do
    assert Money.to_string(usd(-500)) == "-$5.00"
    assert Money.to_string(usd(-500), symbol_space: true) == "-$ 5.00"
    assert Money.to_string(usd(-500), minus_sign_first: false) == "$-5.00"
    assert Money.to_string(eur(-1234)) == "-€12.34"
    assert Money.to_string(xau(-20305)) == "-203.05"
    assert Money.to_string(zar(-1_234_567_890)) == "-R12,345,678.90"
  end

  test "to_string with negative values symbol_on_right true" do
    opts = [symbol_on_right: true]

    assert Money.to_string(usd(-500), opts) == "-5.00$"
    assert Money.to_string(eur(-1234), opts) == "-12.34€"
    assert Money.to_string(xau(-20305), opts) == "-203.05"
    assert Money.to_string(zar(-1_234_567_890), opts) == "-12,345,678.90R"
  end

  test "to_string with fractional_unit false" do
    assert Money.to_string(usd(500), fractional_unit: false) == "$5"
    assert Money.to_string(eur(1234), fractional_unit: false) == "€12"
    assert Money.to_string(xau(20305), fractional_unit: false) == "203"
    assert Money.to_string(zar(1_234_567_890), fractional_unit: false) == "R12,345,678"
  end

  test "to_string with strip_insignificant_zeros true" do
    assert Money.to_string(usd(500), strip_insignificant_zeros: true) == "$5"
    assert Money.to_string(eur(1234), strip_insignificant_zeros: true) == "€12.34"
    assert Money.to_string(xau(20305), strip_insignificant_zeros: true) == "203.05"
    assert Money.to_string(zar(1_234_567_890), strip_insignificant_zeros: true) == "R12,345,678.9"
  end

  test "to_string with strip_insignificant_fractional_unit" do
    assert Money.to_string(usd(500), strip_insignificant_fractional_unit: true) == "$5"
    assert Money.to_string(zar(1_234_567_890), strip_insignificant_fractional_unit: true) == "R12,345,678.90"
    assert Money.to_string(xau(20305), strip_insignificant_fractional_unit: true) == "203.05"
  end

  test "to_string with code true" do
    assert Money.to_string(usd(500), code: true) == "$5.00 USD"
    assert Money.to_string(eur(1234), code: true) == "€12.34 EUR"
    assert Money.to_string(xau(20305), code: true) == "203.05 XAU"
    assert Money.to_string(zar(1_234_567_890), code: true) == "R12,345,678.90 ZAR"
  end

  test "to_string with different exponents" do
    assert Money.to_string(jpy(1_234)) == "¥1,234"
    assert Money.to_string(eur(1_234)) == "€12.34"
    assert Money.to_string(usd(10)) == "$0.10"
    assert Money.to_string(clf(20)) == "$0.0020"
    assert Money.to_string(clf(1_234_567)) == "$123.4567"
    assert Money.to_string(usd(12_345_678)) == "$123,456.78"
    assert Money.to_string(usd(123_456_789)) == "$1,234,567.89"

    assert Money.to_string(usd(123_456_789_123_456_789_123_456_789_123_456_789)) ==
             "$1,234,567,891,234,567,891,234,567,891,234,567.89"
  end

  test "to_string configuration defaults" do
    try do
      Application.put_env(:money, :separator, ".")
      Application.put_env(:money, :delimiter, ",")
      Application.put_env(:money, :symbol, false)
      Application.put_env(:money, :symbol_on_right, false)
      Application.put_env(:money, :symbol_space, false)

      assert Money.to_string(zar(1_234_567_890)) == "12.345.678,90"
      assert Money.to_string(zar(1_234_567_890), separator: "|", delimiter: "§", symbol: true) == "R12|345|678§90"

      assert Money.to_string(zar(1_234_567_890), separator: "|", delimiter: "§", symbol: true, symbol_on_right: true) ==
               "12|345|678§90R"

      assert Money.to_string(zar(1_234_567_890),
               separator: "|",
               delimiter: "§",
               symbol: true,
               symbol_on_right: true,
               symbol_space: true
             ) == "12|345|678§90 R"

      assert Money.to_string(zar(1_234_567_890), separator: "|", delimiter: "§", symbol: true, symbol_space: true) ==
               "R 12|345|678§90"
    after
      Application.delete_env(:money, :separator)
      Application.delete_env(:money, :delimiter)
      Application.delete_env(:money, :symbol)
    end
  end

  test "to_string configuration with custom_display_options" do
    try do
      # Default configuration
      Application.put_env(:money, :separator, ",")
      Application.put_env(:money, :delimeter, ".")
      Application.put_env(:money, :symbol, false)
      Application.put_env(:money, :symbol_on_right, false)
      Application.put_env(:money, :symbol_space, false)
      Application.put_env(:money, :fractional_unit, true)
      Application.put_env(:money, :strip_insignificant_zeros, false)

      # Custom configuration
      Application.put_env(:money, :custom_display_options,
        EUR: %{symbol: true, symbol_on_right: true, symbol_space: true, separator: ".", delimiter: ","},
        JPY: %{symbol: true, symbol_on_right: true, separator: ","},
        ARS: %{symbol: true, symbol_on_right: false, separator: ".", delimiter: ","},
        PEN: %{symbol: true, symbol_on_right: false, symbol_space: true, separator: ",", delimiter: "."},
        BRL: %{symbol: false, separator: ".", delimiter: ","}
      )

      # default configuration test
      assert Money.to_string(usd(1_234_567_890)) == "12,345,678.90"

      # custom configuration test
      assert Money.to_string(eur(1_234_567_890)) == "12.345.678,90 €"
      assert Money.to_string(jpy(1_234_567_890)) == "1,234,567,890¥"
      assert Money.to_string(ars(1_234_567_890)) == "$12.345.678,90"
      assert Money.to_string(pen(1_234_567_890)) == "S/ 12,345,678.90"
      assert Money.to_string(brl(1_234_567_8900)) == "123.456.789,00"

      # overwriting with options
      assert Money.to_string(eur(1_234_567_890), symbol: false) == "12.345.678,90"
      assert Money.to_string(jpy(1_234_567_890), symbol_space: true) == "1,234,567,890 ¥"
      assert Money.to_string(ars(1_234_567_890), symbol_on_right: true) == "12.345.678,90$"
      assert Money.to_string(pen(1_234_567_890), fractional_unit: false, symbol_space: false) == "S/12,345,678"
      assert Money.to_string(brl(1_234_567_8900), symbol: true, strip_insignificant_zeros: true) == "R$123.456.789"
    after
      Application.delete_env(:money, :separator)
      Application.delete_env(:money, :delimeter)
      Application.delete_env(:money, :symbol)
      Application.delete_env(:money, :symbol_on_right)
      Application.delete_env(:money, :symbol_space)
      Application.delete_env(:money, :fractional_unit)
      Application.delete_env(:money, :strip_insignificant_zeros)

      Application.delete_env(:money, :custom_display_options)
    end
  end

  test "to_string configuration with old delimeter" do
    try do
      Application.put_env(:money, :separator, ".")
      Application.put_env(:money, :delimeter, ",")
      Application.put_env(:money, :symbol, false)
      Application.put_env(:money, :symbol_on_right, false)
      Application.put_env(:money, :symbol_space, false)
      Application.put_env(:money, :fractional_unit, true)
      Application.put_env(:money, :strip_insignificant_zeros, false)

      assert Money.to_string(zar(1_234_567_890)) == "12.345.678,90"
      assert Money.to_string(zar(1_234_567_890), separator: "|", delimeter: "§", symbol: true) == "R12|345|678§90"

      assert Money.to_string(zar(1_234_567_890), separator: "|", delimeter: "§", symbol: true, symbol_on_right: true) ==
               "12|345|678§90R"

      assert Money.to_string(zar(1_234_567_890),
               separator: "|",
               delimeter: "§",
               symbol: true,
               symbol_on_right: true,
               symbol_space: true
             ) == "12|345|678§90 R"

      assert Money.to_string(zar(1_234_567_890), separator: "|", delimeter: "§", symbol: true, symbol_space: true) ==
               "R 12|345|678§90"

      assert Money.to_string(zar(1_234_567_890),
               separator: "|",
               delimeter: "§",
               symbol: true,
               symbol_space: true,
               fractional_unit: false
             ) == "R 12|345|678"

      assert Money.to_string(zar(1_234_567_890),
               separator: "|",
               delimeter: "§",
               symbol: true,
               symbol_space: true,
               strip_insignificant_zeros: true
             ) == "R 12|345|678§9"
    after
      Application.delete_env(:money, :separator)
      Application.delete_env(:money, :delimeter)
      Application.delete_env(:money, :symbol)
    end
  end

  test "to_string with passed old delimeter" do
    assert Money.to_string(Money.new(100, "USD"), symbol: false, delimeter: ",") == "1,00"
  end

  test "to_string protocol" do
    m = usd(500)
    assert to_string(m) == Money.to_string(m)
  end

  test "to_decimal" do
    assert Money.to_decimal(Money.new(150, "USD")) == Decimal.new(1, 150, -2)
    assert Money.to_decimal(Money.new(89130, "USD")) == Decimal.new(1, 89130, -2)
    assert Money.to_decimal(Money.new(0, "USD")) == Decimal.new(1, 0, -2)
  end

  describe "round/2" do
    test "no decimal places" do
      assert %Money{amount: 100_000} = Money.round(usd(100_045))
      assert %Money{amount: 100_100} = Money.round(eur(100_078))
      assert %Money{amount: 120_100_045} = Money.round(jpy(120_100_045))
    end

    test "with significant digits" do
      assert %Money{amount: 124_000} = Money.round(usd(123_789), -1)
      assert %Money{amount: 650_000} = Money.round(eur(654_321), -2)
      assert %Money{amount: 120_100_000} = Money.round(jpy(120_100_445), -3)
    end

    test "with positive places" do
      # For currencies with fractional units (e.g. GBP, EUR, USD, etc.), users can pass a positive number for
      # the `places` argument to round the fractional units.
      assert %Money{amount: 123_790} = Money.round(usd(123_789), 1)
      assert %Money{amount: 654_320} = Money.round(eur(654_321), 1)

      # `places` values equal to or higher than the exponent have no effect
      assert %Money{amount: 654_321} = Money.round(eur(654_321), 2)
      assert %Money{amount: 654_321} = Money.round(eur(654_321), 3)
      assert %Money{amount: 120_100_445} = Money.round(jpy(120_100_445), 1)
    end

    test "with the rounding mode in Decimal's context" do
      Decimal.Context.with(%Decimal.Context{rounding: :down}, fn ->
        assert %Money{amount: 123_400} = Money.round(usd(123_456), 0)
        assert %Money{amount: 120_100_045} = Money.round(jpy(120_100_045), 0)
      end)

      Decimal.Context.with(%Decimal.Context{rounding: :up}, fn ->
        assert %Money{amount: 654_400} = Money.round(eur(654_321), 0)
      end)
    end
  end
end
