defmodule Money.Sigils do
  @doc ~S"""
  Handles the sigil `~M` for Money

  The lower case `~m` variant does not exist as interpolation and excape characters are not useful for Money sigils.

  ## Usage

      import Money.Sigils
      ~M[1000] # With a configured default currency (e.g. GBP)
      #> %Money{amount: 1000, currency: :GBP3}

      ~M[1000]USD
      #> %Money{amount: 1000, currency: :USD}
  """
  def sigil_M(amount, []),
    do: Money.new(to_integer(amount))
  def sigil_M(amount, [_,_,_]=currency),
    do: Money.new(to_integer(amount), List.to_existing_atom(currency))

  defp to_integer(string) do
    string
    |> String.replace("_", "")
    |> String.to_integer
  end
end
