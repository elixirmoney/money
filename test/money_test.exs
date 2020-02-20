defmodule MoneyTest do
  use ExUnit.Case, async: true
  doctest Money

  require Money.Currency
  import Money.Currency, only: [usd: 1, eur: 1, clf: 1, jpy: 1, omr: 1, xau: 1, zar: 1]

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
    assert Money.parse(Decimal.from_float(4000.456), :USD) == {:ok, usd(4000_46)}

    assert Money.parse(".25", :USD) == {:ok, usd(25)}
    assert Money.parse(",25", :EUR, separator: ".", delimiter: ",") == {:ok, eur(25)}
    assert Money.parse("-,25", :EUR, separator: ".", delimiter: ",") == {:ok, eur(-25)}

    assert Money.parse("1000.0", :WRONG) == :error
  end

  test "parse/3 with options" do
    assert Money.parse("€1.000,00", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("€ 1.000,00", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("$ 1.000,0", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("€ 1000,0", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
    assert Money.parse("1000,0", :EUR, separator: ".", delimiter: ",") == {:ok, eur(100_000)}
  end

  test "parse/2 with default currency set" do
    try do
      Application.put_env(:money, :default_currency, :GBP)
      assert Money.parse("£1,234.56") == {:ok, Money.new(123_456, :GBP)}
    after
      Application.delete_env(:money, :default_currency)
    end
  end

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

  test "test to_string" do
    assert Money.to_string(usd(500)) == "$5.00"
    assert Money.to_string(eur(1234)) == "€12.34"
    assert Money.to_string(xau(20305)) == "203.05"
    assert Money.to_string(zar(1_234_567_890)) == "R12,345,678.90"
  end

  test "to_string with negative values" do
    assert Money.to_string(usd(-500)) == "$-5.00"
    assert Money.to_string(eur(-1234)) == "€-12.34"
    assert Money.to_string(xau(-20305)) == "-203.05"
    assert Money.to_string(zar(-1_234_567_890)) == "R-12,345,678.90"
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

  test "to_string with different exponents" do
    assert Money.to_string(jpy(1_234)) == "¥1,234"
    assert Money.to_string(eur(1_234)) == "€12.34"
    assert Money.to_string(usd(10)) == "$0.10"
    assert Money.to_string(clf(20)) == "$0.0020"
    assert Money.to_string(clf(1_234_567)) == "$123.4567"
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
    assert Money.to_decimal(Money.new(150, "USD")) == Decimal.from_float(1.5)
    assert Money.to_decimal(Money.new(89130, "USD")) == Decimal.from_float(891.3)
  end
end
