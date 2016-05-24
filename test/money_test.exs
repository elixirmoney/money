defmodule MoneyTest do
	use ExUnit.Case

  require Money.Currency
  import Money.Currency

  test "new/2 requires existing currency" do
    assert_raise ArgumentError, fn ->
      Money.new(123, :ABC)
    end
  end

	test "test factory USD" do
		assert Money.new(123, :USD) == usd(123)
	end

	test "test factory EUR" do
		assert Money.new(124, :EUR) == eur(124)
	end

	test "test factory with string" do
		assert Money.new("+124", :EUR) == eur(124)
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
	end

	test "test add" do
		assert Money.add(Money.new(100, :USD), Money.new(200, :USD)) == Money.new(300, :USD)
	end

	test "add error" do
		assert_raise ArgumentError, fn ->
			Money.add(Money.new(124, :EUR), Money.new(123, :USD))
		end
	end

	test "test subtract" do
		assert Money.subtract(Money.new(200, :USD), Money.new(100, :USD)) == Money.new(100, :USD)
	end

	test "subtract error" do
		assert_raise ArgumentError, fn ->
			Money.subtract(Money.new(124, :EUR), Money.new(123, :USD))
		end
	end

	test "test multiply" do
		assert Money.multiply(Money.new(200, :USD), Money.new(100, :USD)) == Money.new(20000, :USD)
	end

	test "test multiply with a multiplier" do
		assert Money.multiply(Money.new(200, :USD), 3) == Money.new(600, :USD)
	end

	test "multiply error" do
		assert_raise ArgumentError, fn ->
			Money.multiply(Money.new(124, :EUR), Money.new(123, :USD))
		end
	end

	test "test divide" do
		assert Money.divide(Money.new(200, :USD), Money.new(100, :USD)) == Money.new(2, :USD)
	end

	test "test divide2" do
		assert Money.divide(Money.new(139, :USD), Money.new(113, :USD)) == Money.new(1, :USD)
	end

	test "divide error" do
		assert_raise ArgumentError, fn ->
			Money.divide(Money.new(124, :EUR), Money.new(123, :USD))
		end
	end

	test "test to_string" do
		assert Money.to_string(usd(500)) == "$5.00"
		assert Money.to_string(eur(123)) == "€1.23"
		assert Money.to_string(nad(203)) == "2.03"
		assert Money.to_string(zar(1234567890)) == "R12,345,678.90"
	end
end
