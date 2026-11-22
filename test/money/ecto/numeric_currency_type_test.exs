defmodule Money.Ecto.NumericCurrency.TypeTest do
  use ExUnit.Case, async: false

  alias Money.Ecto.NumericCurrency.Type

  doctest Type

  test "type/0" do
    assert Type.type() == :integer
  end

  test "cast/1 integer that is currency code" do
    assert Type.cast(840) == {:ok, :USD}
    assert Type.cast(694) == {:ok, :SLL}
  end

  test "every currency except ANG round-trips through dump/1 and load/1" do
    for {currency, _} <- Money.Currency.all(), currency != :ANG do
      {:ok, number} = Type.dump(currency)

      assert Type.load(number) == {:ok, currency}, "#{currency} dumped as #{number} but loaded back differently"
    end
  end

  test "load/1 of a number shared by ANG and XCG returns XCG" do
    assert Type.dump(:ANG) == {:ok, 532}
    assert Type.load(532) == {:ok, :XCG}
  end

  test "cast/1 integer that is not currency code" do
    assert Type.cast(1111) == :error
  end

  test "cast/1 Money" do
    assert Type.cast(Money.new(1000, 826)) == {:ok, :GBP}
  end

  test "cast/1 other" do
    assert Type.cast(1) == :error
    assert Type.cast(true) == :error
  end

  test "load/1 string" do
    assert Type.load(901) == {:ok, :TWD}
  end

  test "dump/1 atom" do
    assert Type.dump(:CHF) == {:ok, 756}
  end

  test "dump/1 other" do
    assert Type.dump({:a, :b}) == :error
  end
end
