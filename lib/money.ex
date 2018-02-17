defmodule FinancialSystem.Money do
  @moduledoc """
    Data structure to handle money operations. 
  """

  defstruct integer_part: nil, fractional_part: nil, currency: nil

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  def new(amount, %Currency{} = currency) do
    if not valid_amount?(amount) do
      raise "Invalid amount format"
    end
    {:ok, 
      %Money{
        integer_part: get_integer_part(amount),
        fractional_part: get_fractional_part(amount, currency.decimal_places),
        currency: currency
      }
    }
  end

  def get_integer_part(amount) do
    {integer_part, _tail} = Integer.parse(amount)
    integer_part
  end

  def get_fractional_part(amount, decimal_places) do
    {_integer_part, str_fractional} = Integer.parse(amount)
    str_fractional = String.trim(str_fractional, ".")
    exponent = decimal_places - String.length(str_fractional)
    exponent = max(0, exponent)
    trunc(String.to_integer(str_fractional) * :math.pow(10, exponent))
  end

  def valid_amount?(amount) when is_binary(amount) do
    not String.match?(amount, ~r/([A-z]+|\s+)/) and
    (length(String.split(amount, ".")) == 2 or
     length(String.split(amount, ".")) == 1)
  end

  def valid_amount?(amount) when is_number(amount), do: false

  def add(%Money{} = money1, value) when is_binary(value) do
    {:ok, money2} = Money.new(value, money1.currency)
    add(money1, money2)
  end

  def add(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise "Can't add different currencies"

    total = get_value_in_minor_units(money1) + get_value_in_minor_units(money2)

    %Money{
      integer_part: div(total, get_power(money1)),
      fractional_part: rem(total, get_power(money1)),
      currency: money1.currency
    }
  end

  def subtract(%Money{} = money1, value) when is_binary(value) do
    {:ok, money2} = Money.new(value, money1.currency)
    subtract(money1, money2)
  end


  @doc """
    Subtract value of second money from the first money.
  """
  def subtract(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise "Can't subtract different currencies"

    total = get_value_in_minor_units(money1) - get_value_in_minor_units(money2)

    %Money{
      integer_part: div(total, get_power(money1)),
      fractional_part: rem(total, get_power(money1)),
      currency: money1.currency
    }
  end

  defp get_value_in_minor_units(%Money{} = money) do
    money.integer_part * get_power(money) + money.fractional_part
  end

  defp get_power(%Money{} = money) do
    trunc(:math.pow(10, money.currency.decimal_places))
  end
end
