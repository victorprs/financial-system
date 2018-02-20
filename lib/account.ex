defmodule FinancialSystem.Account do
  @moduledoc """
    Data structure to store account properties. 
    
    Each account has a balance that represents the funds that it has in a
    `FinancialSystem.Money` struct and its respective `FinancialSystem.Currency`.
    Each account also has an owner with its name represented by the `owner`
    string. And of course, an account number to uniquely identify an account.
  """

  defstruct number: nil, balance: nil, owner: nil

  alias FinancialSystem.Currency
  alias FinancialSystem.Money
  alias FinancialSystem.Account

  @doc """
    Creates a new `FinancialSystem.Account` with the given account number, 
    the respective balance funds that the account should have and the owner's
    name

  ## Examples
  
      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("42.42", currency)
      iex> FinancialSystem.Account.new(123, money, "Arthur Dent")
      {:ok, %FinancialSystem.Account{
        balance: %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 4242,
          precision: 2
          },
        number: 123,
        owner: "Arthur Dent"
      }}

  """
  def new(number, %Money{} = balance, owner) when is_binary(owner) and is_integer(number) do
    case Currency.valid?(balance.currency) do
      :ok ->
        {:ok, %Account{number: number, balance: balance, owner: owner}}
    end
  end

  @doc """
    Check if the given account has enough funds to withdraw the given amount.

  ## Example

      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("42.42", currency)
      iex> {:ok, acc} = FinancialSystem.Account.new(123, money, "Arthur Dent")
      iex> FinancialSystem.Account.has_enough_funds?(acc, "42.42")
      true
  """
  def has_enough_funds?(%Account{} = account, amount) when is_binary(amount) do
    case Money.valid_amount?(amount) do
      true -> 
        new_money = Money.subtract(account.balance, amount)
        new_money.minor_units >= 0
      false ->
        raise "Invalid amount format"
    end
  end
end
