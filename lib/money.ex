defmodule FinancialSystem.Money do
  @moduledoc """
    Data structure to handle money operations. 
  """

  defstruct integer_part: nil, fractional_part: nil, currency: nil

  alias FinancialSystem.Currency

  def new(amount, %Currency{} = currency) do
    if not valid_amount?(amount) do
      raise "Invalid amount format"
    end
    {:ok, 
      %FinancialSystem.Money{
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
    fractional_part =
      trunc(String.to_integer(str_fractional) * :math.pow(10, exponent))
  end

  def valid_amount?(amount) when is_binary(amount) do
    not String.match?(amount, ~r/([A-z]+|\s+)/) and
    (length(String.split(amount, ".")) == 2 or
     length(String.split(amount, ".")) == 1)
  end

  def valid_amount?(amount) when is_number(amount), do: false
end
