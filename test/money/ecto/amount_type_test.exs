defmodule Money.Ecto.Amount.TypeTest do
  use ExUnit.Case, async: false

  alias Money.Ecto.Amount.Type

  doctest Type

  setup do
    Application.put_env(:money, :default_currency, :GBP)

    on_exit(fn ->
      Application.delete_env(:money, :default_currency)
    end)
  end

  test "type/0" do
    assert Type.type() == :integer
  end

  test "cast/1 String" do
    assert Type.cast("1000") == {:ok, Money.new(100_000, :GBP)}
    assert Type.cast("1234.56") == {:ok, Money.new(123_456, :GBP)}
    assert Type.cast("1,234.56") == {:ok, Money.new(123_456, :GBP)}
    assert Type.cast("£1234.56") == {:ok, Money.new(123_456, :GBP)}
    assert Type.cast("£1,234.56") == {:ok, Money.new(123_456, :GBP)}
    assert Type.cast("£ 1234.56") == {:ok, Money.new(123_456, :GBP)}
    assert Type.cast("£ 1,234.56") == {:ok, Money.new(123_456, :GBP)}
    assert Type.cast("£ 1234") == {:ok, Money.new(123_400, :GBP)}
    assert Type.cast("£ 1,234") == {:ok, Money.new(123_400, :GBP)}
  end

  test "cast/1 integer" do
    assert Type.cast(1000) == {:ok, Money.new(1000, :GBP)}
  end

  test "cast/1 Money" do
    assert Type.cast(Money.new(1000)) == {:ok, Money.new(1000, :GBP)}
  end

  test "cast/1 Map" do
    assert Type.cast(%{"amount" => 1000, "currency" => "EUR"}) == :error
    assert Type.cast(%{"amount" => 1000, "currency" => "GBP"}) == {:ok, Money.new(1000, :GBP)}
    assert Type.cast(%{"amount" => 1000, "currency" => "gbp"}) == {:ok, Money.new(1000, :GBP)}
    assert Type.cast(%{"amount" => 1000}) == {:ok, Money.new(1000, :GBP)}
    assert Type.cast(%{amount: 1000, currency: "GBP"}) == {:ok, Money.new(1000, :GBP)}
    assert Type.cast(%{amount: 1000, currency: "EUR"}) == :error
    assert Type.cast(%{amount: 1000, currency: "gbp"}) == {:ok, Money.new(1000, :GBP)}
    assert Type.cast(%{amount: 1000}) == {:ok, Money.new(1000, :GBP)}
  end

  test "cast/1 other" do
    assert Type.cast([]) == :error
  end

  test "load/1 integer" do
    assert Type.load(1000) == {:ok, Money.new(1000, :GBP)}
  end

  test "load/1 map" do
    assert Type.load(%{amount: 1_619_00, currency: "USD"}) == {:ok, Money.new(1_619_00, :USD)}
  end

  test "dump/1 integer" do
    assert Type.dump(1000) == {:ok, 1000}
  end

  test "dump/1 Money" do
    assert Type.dump(Money.new(1000, :GBP)) == {:ok, 1000}
  end

  test "dump/1 other" do
    assert Type.dump([]) == :error
  end
end
