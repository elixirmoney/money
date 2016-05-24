defmodule MoneyTest do
	use ExUnit.Case

	require Money

	test "test factory USD" do
		assert Money.new(123, :USD) == Money.usd(123)
	end

	test "test factory EUR" do
		assert Money.new(124, :EUR) == Money.eur(124)
	end

	test "test factory with string" do
		assert Money.new("+124", :EUR) == Money.eur(124)
	end

	test "test factory non esistent Currency" do
		assert_raise CondClauseError, fn ->
		    Money.new(124, :paradise) == nil
		end
	end

	test "conversion error" do
		assert_raise FunctionClauseError, fn ->
		  Money.new(:atom, :USD)
		end
	end

	test "currencies name" do
		assert Money.currency_name(:USD) == "US Dollar"
	end

	test "currencies nil name" do
		assert Money.currency_name(:liuggio) == nil
	end

	test "currencies symbol" do
		assert Money.currency_symbol(:USD) == "$"
	end

	test "currencies nil symbol" do
		assert Money.currency_symbol(:liuggio) == nil
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
		assert Money.equals?(Money.new(123, :USD), Money.usd(123))
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

	test "test currency symbol to a Money map" do
		assert Money.currency_symbol(Money.afn(500)) == "؋"
	end

	test "test currency name to a Money map" do
		assert Money.currency_name(Money.afn(500)) == "Afghani"
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
		assert Money.to_string(Money.usd(500)) == "$5.00"
		assert Money.to_string(Money.eur(123)) == "€1.23"
		assert Money.to_string(Money.nad(203)) == "2.03"
		assert Money.to_string(Money.zar(1234567890)) == "R12,345,678.90"
	end
end
