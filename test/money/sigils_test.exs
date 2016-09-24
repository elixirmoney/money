defmodule Money.SigilsTest do
  use ExUnit.Case, async: true
  doctest Money.Sigils

  import Money.Sigils

  setup do
    Application.put_env(:money, :default_currency, :GBP)

    on_exit fn ->
      Application.delete_env(:money, :default_currency)
    end
  end

  test "it can create a money object from a sigil" do
    assert ~M[1000] == Money.new(1000, :GBP)
  end

  test "it can handle underscores like normal integers" do
    assert ~M[1_000] == Money.new(1000, :GBP)
    assert ~M[1_000_00] == Money.new(100000, :GBP)
  end

  test "it can create a money object from a sigil with a currency" do
    assert ~M[1000]USD == Money.new(1000, :USD)
    assert ~M[1000]GBP == Money.new(1000, :GBP)
    assert ~M[1000]EUR == Money.new(1000, :EUR)
  end

  test "it fails with anything other than a three character country code" do
    assert_raise FunctionClauseError, fn ->
      ~M[1000]U
    end
    assert_raise FunctionClauseError, fn ->
      ~M[1000]US
    end
    assert_raise FunctionClauseError, fn ->
      ~M[1000]EURO
    end
  end
end
