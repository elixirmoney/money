defmodule Money.DisplayOptions do
  @moduledoc false
  alias Money.Currency
  alias Money.ParseOptions

  @type t :: %__MODULE__{
          separator: String.t(),
          delimiter: String.t(),
          symbol: String.t(),
          symbol_on_right: boolean(),
          symbol_space: boolean(),
          fractional_unit: boolean(),
          strip_insignificant_zeros: boolean(),
          code: boolean(),
          minus_sign_first: boolean(),
          strip_insignificant_fractional_unit: boolean()
        }

  @all_fields [
    :separator,
    :delimiter,
    :symbol,
    :symbol_on_right,
    :symbol_space,
    :fractional_unit,
    :strip_insignificant_zeros,
    :code,
    :minus_sign_first,
    :strip_insignificant_fractional_unit
  ]
  @enforce_keys @all_fields
  defstruct @all_fields

  @spec get(Money.t(), Keyword.t()) :: t()
  def get(%Money{} = money, opts) do
    %{separator: separator, delimiter: delimiter} = ParseOptions.get(opts)

    default_symbol = Application.get_env(:money, :symbol, true)
    default_symbol_on_right = Application.get_env(:money, :symbol_on_right, false)
    default_symbol_space = Application.get_env(:money, :symbol_space, false)
    default_fractional_unit = Application.get_env(:money, :fractional_unit, true)
    default_strip_insignificant_zeros = Application.get_env(:money, :strip_insignificant_zeros, false)
    default_code = Application.get_env(:money, :code, false)
    default_minus_sign_first = Application.get_env(:money, :minus_sign_first, true)

    default_strip_insignificant_fractional_unit =
      Application.get_env(:money, :strip_insignificant_fractional_unit, false)

    symbol = if Keyword.get(opts, :symbol, default_symbol), do: Currency.symbol(money), else: ""
    symbol_on_right = Keyword.get(opts, :symbol_on_right, default_symbol_on_right)
    symbol_space = Keyword.get(opts, :symbol_space, default_symbol_space)
    fractional_unit = Keyword.get(opts, :fractional_unit, default_fractional_unit)
    strip_insignificant_zeros = Keyword.get(opts, :strip_insignificant_zeros, default_strip_insignificant_zeros)
    code = Keyword.get(opts, :code, default_code)
    minus_sign_first = Keyword.get(opts, :minus_sign_first, default_minus_sign_first)

    strip_insignificant_fractional_unit =
      Keyword.get(opts, :strip_insignificant_fractional_unit, default_strip_insignificant_fractional_unit)

    %__MODULE__{
      separator: separator,
      delimiter: delimiter,
      symbol: symbol,
      symbol_on_right: symbol_on_right,
      symbol_space: symbol_space,
      fractional_unit: fractional_unit,
      strip_insignificant_zeros: strip_insignificant_zeros,
      code: code,
      minus_sign_first: minus_sign_first,
      strip_insignificant_fractional_unit: strip_insignificant_fractional_unit
    }
  end
end
