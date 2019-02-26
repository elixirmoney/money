defmodule Money.Ecto.Map.TypeTest do
  use ExUnit.Case, async: false

  alias Money.Ecto.Map.Type

  doctest Type

  test "type/0" do
    assert Type.type() == :map
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

  test "load/1 map with integer amount" do
    assert Type.load(%{"amount" => 1, "currency" => "USD"}) == {:ok, Money.new(1, :USD)}
    assert Type.load(%{"amount" => 100, "currency" => "JPY"}) == {:ok, Money.new(100, :JPY)}
  end

  test "load/1 map with binary amount" do
    assert Type.load(%{"amount" => "1", "currency" => "USD"}) == {:ok, Money.new(1, :USD)}
    assert Type.load(%{"amount" => "100", "currency" => "JPY"}) == {:ok, Money.new(100, :JPY)}
  end

  test "dump/1 Money" do
    assert Type.dump(Money.new(1, :USD)) == {:ok, %{"amount" => 1, "currency" => "USD"}}
    assert Type.dump(Money.new(100, :JPY)) == {:ok, %{"amount" => 100, "currency" => "JPY"}}
  end

  test "dump/1 other" do
    assert Type.dump([]) == :error
  end
end
