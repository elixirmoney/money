defmodule Money.ParseOptions do
  @moduledoc false

  @type t :: %__MODULE__{
          separator: String.t(),
          delimiter: String.t()
        }

  @enforce_keys [:separator, :delimiter]
  defstruct [:separator, :delimiter]

  @spec get(Keyword.t()) :: t()
  def get(opts) do
    default_separator = Application.get_env(:money, :separator, ",")
    separator = Keyword.get(opts, :separator, default_separator)

    default_delimiter = Application.get_env(:money, :delimiter) || Application.get_env(:money, :delimeter, ".")
    delimiter = Keyword.get(opts, :delimiter) || Keyword.get(opts, :delimeter, default_delimiter)

    %__MODULE__{separator: separator, delimiter: delimiter}
  end
end
