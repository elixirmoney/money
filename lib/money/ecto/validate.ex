defmodule Money.Ecto.Validate do
  @moduledoc """
  Implements Ecto validations for the `t:Money.t/0` type based upon the
  `Money.Ecto.Composite.Type` type.

  """

  @money_validators %{
    less_than: "must be less than %{money}",
    greater_than: "must be greater than %{money}",
    less_than_or_equal_to: "must be less than or equal to %{money}",
    greater_than_or_equal_to: "must be greater than or equal to %{money}",
    equal_to: "must be equal to %{money}",
    not_equal_to: "must be not equal to %{money}"
  }

  @doc """
  Validates the properties of a `t:Money.t/0`.

  This function, including its options, is designed to
  mirror the function `Ecto.Changeset.validate_number/3`.

  ## Options

    * `:less_than`
    * `:greater_than`
    * `:less_than_or_equal_to`
    * `:greater_than_or_equal_to`
    * `:equal_to`
    * `:not_equal_to`
    * `:message` - the message on failure, defaults to one of:
      * "must be less than %{money}"
      * "must be greater than %{money}"
      * "must be less than or equal to %{money}"
      * "must be greater than or equal to %{money}"
      * "must be equal to %{money}"
      * "must be not equal to %{money}"

  ## Examples

    validate_money(changeset, :value, less_than: Money.new(:USD, 200))
    validate_money(changeset, :value, less_than_or_equal_to: Money.new(:USD, 200)
    validate_money(changeset, :value, less_than_or_equal_to: Money.new(:USD, 100))
    validate_money(changeset, :value, greater_than: Money.new(:USD, 50))
    validate_money(changeset, :value, greater_than_or_equal_to: Money.new(:USD, 50))
    validate_money(changeset, :value, greater_than_or_equal_to: Money.new(:USD, 100))

  """
  @spec validate_money(Ecto.Changeset.t(), atom, Keyword.t()) :: Ecto.Changeset.t()
  def validate_money(changeset, field, opts) do
    Ecto.Changeset.validate_change(changeset, field, {:money, opts}, fn
      field, value ->
        {message, opts} = Keyword.pop(opts, :message)

        Enum.find_value(opts, [], fn {spec_key, target_value} ->
          # credo:disable-for-next-line
          case Map.fetch(@money_validators, spec_key) do
            {:ok, default_message} ->
              validate_money(field, value, message || default_message, spec_key, target_value)

            :error ->
              supported_options = @money_validators |> Map.keys()

              raise ArgumentError, """
              unknown option #{inspect(spec_key)} given to validate_money/3
              The supported options are:
              #{supported_options}
              """
          end
        end)
    end)
  end

  defp validate_money(field, %Money{} = value, message, spec_key, %Money{} = target_value) do
    result = Money.cmp(value, target_value)

    case money_compare(result, spec_key) do
      true ->
        nil

      false ->
        [{field, {message, validation: :money, kind: spec_key, money: target_value}}]

      {:error, {_exception, reason}} ->
        [{field, {reason, validation: :money, kind: spec_key, money: target_value}}]
    end
  end

  defp validate_money(_field, value, _message, _spec_key, %Money{} = _target_value) do
    raise ArgumentError, "expected value to be of type Money, got: #{inspect(value)}"
  end

  defp validate_money(_field, %Money{} = _value, _message, _spec_key, target_value) do
    raise ArgumentError,
          "expected target_value to be of type Money, got: #{inspect(target_value)}"
  end

  defp validate_money(_field, value, _message, _spec_key, target_value) do
    raise ArgumentError,
          "expected value and target_value to be of type Money, " <>
            "got value: #{inspect(value)} and target_value: #{target_value}"
  end

  defp money_compare(:lt, spec), do: spec in [:less_than, :less_than_or_equal_to, :not_equal_to]

  defp money_compare(:gt, spec),
    do: spec in [:greater_than, :greater_than_or_equal_to, :not_equal_to]

  defp money_compare(:eq, spec),
    do: spec in [:equal_to, :less_than_or_equal_to, :greater_than_or_equal_to]

  defp money_compare(other, _spec), do: other
end
