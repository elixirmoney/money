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
    assert Currency.get(:USD) == %{name: "US Dollar", symbol: "$"}
    assert Currency.get(Currency.usd(100)) == %{name: "US Dollar", symbol: "$"}
    assert Currency.get(:ABC) == nil
  end

  test "get!/1" do
    assert Currency.get!(:USD) == %{name: "US Dollar", symbol: "$"}
    assert Currency.get!(Currency.usd(100)) == %{name: "US Dollar", symbol: "$"}
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

	test "to_atom/1" do
		assert Currency.to_atom(:USD) == :USD
		assert Currency.to_atom("USD") == :USD
		assert Currency.to_atom("usd") == :USD
		assert Currency.to_atom(Currency.usd(100)) == :USD
		assert_raise ArgumentError, fn -> Currency.to_atom(:ABC) end
		assert_raise ArgumentError, fn -> Currency.to_atom("ABC") end
		assert_raise ArgumentError, fn -> Currency.to_atom("abc") end
		assert_raise ArgumentError, fn -> Currency.to_atom("abc" <> "khgyujnk") end
	end
end
