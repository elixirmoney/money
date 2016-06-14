if Code.ensure_compiled?(Phoenix.HTML.Safe) do
  defmodule PhoenixHTMLSafeTeset do
    use ExUnit.Case, async: false

    setup do
      Application.put_env(:money, :default_currency, :GBP)

      on_exit fn ->
        Application.delete_env(:money, :default_currency)
      end
    end

    test "Phoenix.HTML.Safe for Money" do
      money = Money.new(123456)

      assert Phoenix.HTML.Safe.to_iodata(money) == Phoenix.HTML.Safe.to_iodata(to_string(money))
    end
  end
end
