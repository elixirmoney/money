if Code.ensure_compiled?(Ecto.Type) do
  defmodule Money.Ecto.TypeTest do
    use ExUnit.Case, async: true
    doctest Money.Ecto.Type

    alias Money.Ecto.Type

    setup do
      Application.put_env(:money, :default_currency, :GBP)

      on_exit fn ->
        Application.delete_env(:money, :default_currency)
      end
    end

    test "type/0" do
      assert Type.type == :integer
    end

    test "cast/1 String" do
      assert Type.cast("1000") == {:ok, Money.new(100000, :GBP)}
      assert Type.cast("1234.56") == {:ok, Money.new(123456, :GBP)}
      assert Type.cast("1,234.56") == {:ok, Money.new(123456, :GBP)}
      assert Type.cast("£1234.56") == {:ok, Money.new(123456, :GBP)}
      assert Type.cast("£1,234.56") == {:ok, Money.new(123456, :GBP)}
      assert Type.cast("£ 1234.56") == {:ok, Money.new(123456, :GBP)}
      assert Type.cast("£ 1,234.56") == {:ok, Money.new(123456, :GBP)}
      assert Type.cast("£ 1234") == {:ok, Money.new(123400, :GBP)}
      assert Type.cast("£ 1,234") == {:ok, Money.new(123400, :GBP)}
    end

    test "cast/1 integer" do
      assert Type.cast(1000) == {:ok, Money.new(1000, :GBP)}
    end

    test "cast/1 other" do
      assert Type.cast([]) == :error
    end

    test "load/1 integer" do
      assert Type.load(1000) == {:ok, Money.new(1000, :GBP)}
    end

    test "dump/1 integer" do
      assert Type.dump(1000) == {:ok, 1000}
    end

    test "dmmp/1 Money" do
      assert Type.dump(Money.new(1000, :GBP)) == {:ok, 1000}
    end

    test "dump/1 other" do
      assert Type.dump([]) == :error
    end
  end
end
