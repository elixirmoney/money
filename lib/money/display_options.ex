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

  defp custom_display_options do
    Enum.into(Application.get_env(:money, :custom_display_options, []), %{})
  end

  @spec get(Money.t(), Keyword.t()) :: t()
  def get(%Money{} = money, opts) do
    custom_currency_display_options = get_currency_custom_display_options(money.currency)

    opts_with_symbol =
      case Keyword.get(opts, :symbol) do
        nil -> opts
        true -> Keyword.put(opts, :symbol, Currency.symbol(money.currency))
        false -> Keyword.put(opts, :symbol, "")
      end

    money
    |> get_defaults(opts)
    |> Map.merge(custom_currency_display_options)
    |> Map.merge(Enum.into(opts_with_symbol, %{}))
  end

  @spec get_defaults(Money.t(), Keyword.t()) :: t()
  defp get_defaults(%Money{} = money, opts) do
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

    %__MODULE__{
      separator: separator,
      delimiter: delimiter,
      symbol: symbol,
      symbol_on_right: default_symbol_on_right,
      symbol_space: default_symbol_space,
      fractional_unit: default_fractional_unit,
      strip_insignificant_zeros: default_strip_insignificant_zeros,
      code: default_code,
      minus_sign_first: default_minus_sign_first,
      strip_insignificant_fractional_unit: default_strip_insignificant_fractional_unit
    }
  end

  defp get_currency_custom_display_options(currency) do
    display_options = Map.get(custom_display_options(), currency, %{})

    case display_options[:symbol] do
      nil -> display_options
      true -> Map.put(display_options, :symbol, Currency.symbol(currency))
      false -> Map.put(display_options, :symbol, "")
    end
  end
end
