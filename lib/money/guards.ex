defmodule Money.Guards do
  @doc """
  Determines if a value is a Money struct.

  Returns `true` if the given `money` is a `Money` struct, otherwise it returns `false`.

  Allowed in guard clauses.
  """
  defguard is_money(money) when is_struct(money, Money)

  @doc """
  Determines if a `Money` has a zero amount.

  Returns `true` if the given `money` is a `Money` struct with a zero amount, otherwise it returns `false`.

  Allowed in guard clauses.
  """
  defguard is_zero(money) when is_money(money) and money.amount == 0

  @doc """
  Determines if a `Money` has a positive amount.

  Returns `true` if the given `money` is a `Money` struct with a positive amount, otherwise it returns `false`.

  Allowed in guard clauses.
  """
  defguard is_positive(money) when is_money(money) and money.amount > 0

  @doc """
  Determines if a `Money` has a negative amount.

  Returns `true` if the given `money` is a `Money` struct with a negative amount, otherwise it returns `false`.

  Allowed in guard clauses.
  """
  defguard is_negative(money) when is_money(money) and money.amount < 0
end
