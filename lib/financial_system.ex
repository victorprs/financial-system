defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  def convert(%Money{} = money, %Currency{} = currency, exchange_rate) when is_binary(exchange_rate) do
    if money.currency == currency, do: raise "Error: same currency conversion"
    Currency.valid?(currency)
    %{Money.multiply(money, exchange_rate) | currency: currency}
  end
end
