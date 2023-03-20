defmodule Money.Ecto.Currency.TypeTest do
  use ExUnit.Case, async: false

  alias Money.Ecto.Currency.Type

  doctest Type

  test "type/0" do
    assert Type.type() == :string
  end

  test "cast/1 string that is currency code" do
    assert Type.cast("USD") == {:ok, :USD}
    assert Type.cast("sll") == {:ok, :SLL}
  end

  test "cast/1 string that is not currency code" do
    assert Type.cast("xxx") == :error
  end

  test "cast/1 atom that is currency code" do
    assert Type.cast(:BRL) == {:ok, :BRL}
  end

  test "cast/1 atom that is not currency code" do
    assert Type.cast(:Z29) == :error
  end

  test "cast/1 Money" do
    assert Type.cast(Money.new(1000, :GBP)) == {:ok, :GBP}
  end

  test "cast/1 other" do
    assert Type.cast(1) == :error
    assert Type.cast(true) == :error
  end

  test "load/1 string" do
    assert Type.load("TWD") == {:ok, :TWD}
  end

  test "dump/1 atom" do
    assert Type.dump(:CHF) == {:ok, "CHF"}
  end

  test "dump/1 string" do
    assert Type.dump("CHF") == {:ok, "CHF"}
  end

  test "dump/1 other" do
    assert Type.dump({:a, :b}) == :error
  end
end
