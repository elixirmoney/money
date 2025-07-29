defmodule Money.Ecto.Composite.TypeTest do
  use ExUnit.Case, async: false

  alias Money.Ecto.Composite.Type

  doctest Type

  test "type/0" do
    assert Type.type() == :money_with_currency
  end

  test "cast/1 Money" do
    assert Type.cast(Money.new(1, :USD)) == {:ok, Money.new(1, :USD)}
    assert Type.cast(Money.new(100, :JPY)) == {:ok, Money.new(100, :JPY)}
  end

  test "cast/1 Tuple {amount, currency}" do
    assert Type.cast({1, :USD}) == {:ok, Money.new(1, :USD)}
    assert Type.cast({100, :JPY}) == {:ok, Money.new(100, :JPY)}
  end

  test "cast/1 Map" do
    assert Type.cast(%{"amount" => 1, "currency" => "USD"}) == {:ok, Money.new(1, :USD)}
    assert Type.cast(%{"amount" => 100, "currency" => "JPY"}) == {:ok, Money.new(100, :JPY)}
  end

  test "cast/1 other" do
    assert Type.cast([]) == :error
  end

  test "load/1 Tuple {amount, currency}" do
    assert Type.load({1, "USD"}) == {:ok, Money.new(1, :USD)}
    assert Type.load({100, "JPY"}) == {:ok, Money.new(100, :JPY)}
  end

  test "load/1 Tuple with `Decimal.new/1`: {Decimal.new/1, currency}" do
    assert Type.load({Decimal.new("1"), "USD"}) == {:ok, Money.new(1, :USD)}
    assert Type.load({Decimal.new("1000"), "MXN"}) == {:ok, Money.new(1000, :MXN)}
  end

  test "dump/1 Money" do
    assert Type.dump(Money.new(1, :USD)) == {:ok, {1, "USD"}}
    assert Type.dump(Money.new(100, :JPY)) == {:ok, {100, "JPY"}}
  end

  test "dump/1 other" do
    assert Type.dump([]) == :error
  end
end
