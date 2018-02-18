defmodule FinancialSystem.Money do
  @moduledoc """
    Data structure to handle money operations. 
  """

  defstruct minor_units: nil, precision: nil, currency: nil

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  def new(amount, precision \\ 14, %Currency{} = currency) do
    if not valid_amount?(amount) do
      raise "Invalid amount format"
    end
    {:ok,
      %Money{
        minor_units: string_to_minor_units(amount, precision),
        precision: precision,
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
    {:ok, money2} = Money.new(value, money1.precision, money1.currency)
    add(money1, money2)
  end

  def add(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise "Can't add different currencies"

    total = 
      cond do
        money1.precision == money2.precision ->
          money1.minor_units + money2.minor_units
        money1.precision > money2.precision ->
          money1.minor_units + money2.minor_units * get_power_of_ten(money1.precision - money2.precision)
        money1.precision < money2.precision ->
          money1.minor_units * get_power_of_ten(money2.precision - money1.precision) + money2.minor_units
      end

    %Money{
      minor_units: total,
      precision: max(money1.precision, money2.precision),
      currency: money1.currency
    }
  end

  def subtract(%Money{} = money1, value) when is_binary(value) do
    {:ok, money2} = Money.new(value, money1.precision, money1.currency)
    subtract(money1, money2)
  end


  @doc """
    Subtract value of second money from the first money.
  """
  def subtract(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise "Can't subtract different currencies"

    total = 
      cond do
        money1.precision == money2.precision ->
          money1.minor_units - money2.minor_units
        money1.precision > money2.precision ->
          money1.minor_units - money2.minor_units * get_power_of_ten(money1.precision - money2.precision)
        money1.precision < money2.precision ->
          money1.minor_units * get_power_of_ten(money2.precision - money1.precision) - money2.minor_units
      end

    %Money{
      minor_units: total,
      precision: max(money1.precision, money2.precision),
      currency: money1.currency
    }
  end

@doc """
    Multiply value of money by another value
  """
  def multiply(%Money{} = money, value) when is_binary(value) do
    if not valid_amount?(value), do: raise "Invalid value format"
    value_precision = 
      value 
      |> String.split(".")
      |> List.last
      |> String.length
    %Money{
      minor_units: money.minor_units * string_to_minor_units(value, value_precision),
      precision: money.precision + value_precision,
      currency: money.currency
    }
  end

  def as_string(%Money{} = money) do
    Integer.to_string(div(money.minor_units, get_power_of_ten(money.precision)))
      <> "." <>
      Integer.to_string(rem(money.minor_units, get_power_of_ten(money.precision)))
  end

  defp get_power_of_ten(n) when n == 0 do
    1
  end

  defp get_power_of_ten(n) do
    10 * get_power_of_ten(n-1)
  end

end
