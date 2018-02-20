defmodule FinancialSystem do
  @moduledoc """
  Financial operations with arbitrary-precision.

  `FinancialSystem` is able to convert money from one currency to another with
  one requirement: that the currency is in compliance with 
  [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217), that includes the
  currency's alphabetic and numeric codes and the exponent that represents
  its decimal places. 
  """

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  @doc """
    Converts `money` from its original currency to the new currency given via
    the parameter `currency`, given the `exchange_rate`

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, new_currency} = FinancialSystem.Currency.new("USD", 101, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("10.50", original_currency)
      iex> FinancialSystem.convert(money, new_currency, "3.34")
      %FinancialSystem.Money{
        currency: %FinancialSystem.Currency{
          alphabetic_code: "USD",
          decimal_places: 2,
          numeric_code: 101
        },
        minor_units: 350700,
        precision: 4
      }
    
  """
  def convert(%Money{} = money, %Currency{} = currency, exchange_rate) when is_binary(exchange_rate) do
    if money.currency == currency, do: raise "Error: same currency conversion"
    Currency.valid?(currency)
    %{Money.multiply(money, exchange_rate) | currency: currency}
  end
end
