defmodule Money.SigilsTest do
  use ExUnit.Case, async: true
  doctest Money.Sigils

  import Money.Sigils

  # Set application setting before compilation of the followin tests
  Application.put_env(:money, :default_currency, :GBP)

  test "it can create a money object from a sigil" do
    assert ~M[1000] == Money.new(1000, :GBP)
  end

  test "it can handle underscores like normal integers" do
    assert ~M[1_000] == Money.new(1000, :GBP)
    assert ~M[1_000_00] == Money.new(100000, :GBP)
  end

  # Revert the settins after compilation of the above tests
  Application.delete_env(:money, :default_currency)

  test "it can create a money object from a sigil with a currency" do
    assert ~M[1000]USD == Money.new(1000, :USD)
    assert ~M[1000]GBP == Money.new(1000, :GBP)
    assert ~M[1000]EUR == Money.new(1000, :EUR)
  end

  # This is a convoluted test because I'm trying to test a failing compilation (I'd love a better way to do this)
  try do
    test "it fails to expand the sigil with an invalid currency code" do
      m = ~M[1000]U
      refute m, "This test should have failed"
    end
  rescue
    ArgumentError ->
      test "it fails to expand the sigil with an invalid currency code",
        do: assert Enum.random(1..2), "Failure to expand sigil for invalid currency"
  end
end
