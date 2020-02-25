if Code.ensure_loaded?(Phoenix.HTML.Safe) do
  defmodule PhoenixHTMLSafeTeset do
    use ExUnit.Case, async: true

    alias Phoenix.HTML.Safe

    test "Phoenix.HTML.Safe for Money" do
      money = Money.new(123_456, :EUR)

      assert Safe.to_iodata(money) == Safe.to_iodata(to_string(money))
    end
  end
end
