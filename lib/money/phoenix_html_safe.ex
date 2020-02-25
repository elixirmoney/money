if Code.ensure_loaded?(Phoenix.HTML.Safe) do
  defimpl Phoenix.HTML.Safe, for: Money do
    def to_iodata(money), do: Phoenix.HTML.Safe.to_iodata(to_string(money))
  end
end
