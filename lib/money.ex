defmodule FinancialSystem.Money do
  @moduledoc """
    Data structure to handle money operations. 
  """

  defstruct minor_units: nil, currency: nil

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  def new(amount, %Currency{} = currency) do
    if not valid_amount?(amount) do
      raise "Invalid amount format"
    end
    {:ok,
      %Money{
        minor_units: string_to_minor_units(amount, currency.decimal_places),
        currency: currency
      }
    }
  end

  def valid_amount?(amount) when is_binary(amount) do
    try do
      _ = String.to_float(amount)
      true
    rescue
      ArgumentError -> false
    end
  end

  def valid_amount?(amount) when is_number(amount), do: false

  def string_to_minor_units(amount, decimal_places) do
    {int_part, tail} = Integer.parse(amount)
    fract_part = tail
    |> String.trim(".")
    |> String.pad_trailing(decimal_places, "0")
    |> String.to_integer
    int_part * get_power_of_ten(decimal_places) + fract_part
  end

  def add(%Money{} = money1, value) when is_binary(value) do
    {:ok, money2} = Money.new(value, money1.currency)
    add(money1, money2)
  end

  def add(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise "Can't add different currencies"

    %Money{
      minor_units: money1.minor_units + money2.minor_units,
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

    %Money{
      minor_units: money1.minor_units - money2.minor_units,
      currency: money1.currency
    }
  end

@doc """
    Multiply value of money by another value
  """
  def multiply(%Money{} = money, value) when is_float(value) do
    %Money{
      minor_units: trunc(money.minor_units * value),
      currency: money.currency
    }
  end

  defp get_power_of_ten(n) when n == 0 do
    1
  end

  defp get_power_of_ten(n) do
    10 * get_power_of_ten(n-1)
  end

end
