defmodule Money.GuardsTest do
  use ExUnit.Case, async: true

  defmodule Helper do
    require Money.Guards

    def money?(value) when Money.Guards.is_money(value), do: true
    def money?(_), do: false

    def zero?(money) when Money.Guards.is_zero(money), do: true
    def zero?(_), do: false

    def positive?(money) when Money.Guards.is_positive(money), do: true
    def positive?(_), do: false

    def negative?(money) when Money.Guards.is_negative(money), do: true
    def negative?(_), do: false
  end

  describe "is_money/1" do
    test "returns true for a Money struct" do
      assert Helper.money?(Money.new(100, :USD))
    end

    test "returns false for non-Money values" do
      refute Helper.money?(nil)
      refute Helper.money?(0)
      refute Helper.money?("100")
      refute Helper.money?(%{amount: 100, currency: :USD})
    end
  end

  describe "is_zero/1" do
    test "returns true for zero Money" do
      assert Helper.zero?(Money.new(0, :USD))
    end

    test "returns false for non-zero Money" do
      refute Helper.zero?(Money.new(100, :USD))
      refute Helper.zero?(Money.new(-100, :USD))
    end

    test "returns false for non-Money values" do
      refute Helper.zero?(nil)
      refute Helper.zero?(0)
    end
  end

  describe "is_positive/1" do
    test "returns true for positive Money" do
      assert Helper.positive?(Money.new(100, :USD))
    end

    test "returns false for zero or negative Money" do
      refute Helper.positive?(Money.new(0, :USD))
      refute Helper.positive?(Money.new(-100, :USD))
    end

    test "returns false for non-Money values" do
      refute Helper.positive?(nil)
      refute Helper.positive?(100)
    end
  end

  describe "is_negative/1" do
    test "returns true for negative Money" do
      assert Helper.negative?(Money.new(-100, :USD))
    end

    test "returns false for zero or positive Money" do
      refute Helper.negative?(Money.new(0, :USD))
      refute Helper.negative?(Money.new(100, :USD))
    end

    test "returns false for non-Money values" do
      refute Helper.negative?(nil)
      refute Helper.negative?(-100)
    end
  end
end
