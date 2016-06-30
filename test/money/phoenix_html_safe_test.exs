if Code.ensure_compiled?(Phoenix.HTML.Safe) do
  defmodule PhoenixHTMLSafeTeset do
    use ExUnit.Case, async: true

    test "Phoenix.HTML.Safe for Money" do
      money = Money.new(123456, :EUR)

      assert Phoenix.HTML.Safe.to_iodata(money) == Phoenix.HTML.Safe.to_iodata(to_string(money))
    end
  end
end
