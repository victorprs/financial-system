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
  alias FinancialSystem.Account

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
        minor_units: 3507,
        precision: 2
      }
    
  """
  def convert(%Money{} = money, %Currency{} = currency, exchange_rate)
      when is_binary(exchange_rate) do
    if money.currency == currency, do: raise("Error: same currency conversion")
    Currency.valid?(currency)
    %{Money.multiply(money, exchange_rate) | currency: currency}
  end

  @doc """
    Withdraws the given amount from the given account if the `account`
    has enough funds, i.e., a balance greater than the `amount`.
    
    Returns a new account with the new balance.

  ## Examples

      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("42.42", currency)
      iex> {:ok, acc} = FinancialSystem.Account.new(123, money, "Arthur Dent")
      iex> FinancialSystem.withdraw(acc, "20.00")
      {:ok,
      %FinancialSystem.Account{
        balance: %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 2242,
          precision: 2
        },
        number: 123,
        owner: "Arthur Dent"
      }}

  """
  def withdraw(%Account{} = account, amount) do
    if Account.has_enough_funds?(account, amount) do
      {:ok, %Account{account | balance: Money.subtract(account.balance, amount)}}
    else
      {:error, "Account does not have enough funds to withdraw"}
    end
  end

  @doc """
    Deposits the given amount into the given account.
    
    Returns a new account with the new balance.

  ## Examples

      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("42.42", currency)
      iex> {:ok, acc} = FinancialSystem.Account.new(123, money, "Arthur Dent")
      iex> FinancialSystem.deposit(acc, "20.00")
      {:ok,
      %FinancialSystem.Account{
        balance: %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 6242,
          precision: 2
        },
        number: 123,
        owner: "Arthur Dent"
      }}

  """
  def deposit(%Account{} = account, amount) do
    {:ok, %Account{account | balance: Money.add(account.balance, amount)}}
  end

  @doc """
    Transfer the given amount from the `from_account` to the `to_account`
    if the first one has enough funds, i.e., a balance greater than the
    `amount`.
    
    Returns both new accounts, each with their respectives new balances.

  ## Examples

      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("42.42", currency)
      iex> {:ok, money2} = FinancialSystem.Money.new("0.42", currency)
      iex> {:ok, from_acc} = FinancialSystem.Account.new(123, money, "Arthur Dent")
      iex> {:ok, to_acc} = FinancialSystem.Account.new(234, money2, "Ford Prefect")
      iex> FinancialSystem.transfer(from_acc, to_acc, "20.00")
      {:ok,
      %FinancialSystem.Account{
        balance: %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 2242,
          precision: 2
        },
        number: 123,
        owner: "Arthur Dent"
      },
      %FinancialSystem.Account{
        balance: %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 2042,
          precision: 2
        },
        number: 234,
        owner: "Ford Prefect"
      }}
  """
  def transfer(%Account{} = from_account, %Account{} = to_account, amount) do
    if from_account.number == to_account.number, do: raise("Must transfer to different account")

    if from_account.balance.currency != to_account.balance.currency,
      do: raise("Must convert before transfer to different currencies")

    if Account.has_enough_funds?(from_account, amount) do
      {
        :ok,
        %Account{from_account | balance: Money.subtract(from_account.balance, amount)},
        %Account{to_account | balance: Money.add(to_account.balance, amount)}
      }
    else
      {:error, "Account does not have enough funds to transfer"}
    end
  end

  @doc """
    Transfer the given amount from the `from_account` to the `to_accounts`
    if the first one has enough funds, i.e., a balance greater than the
    `amount`. `to_accounts` is a list of tuples with each tuple having the
    first value as `FinancialSystem.Account` and the second value as the 
    respective percentage of the money that will be transfered to the
    corresponding account, from 0 to 1 in a string format.
    
    Returns the new from_account and a list with the new to_accounts and 
    each with their respectives new balances.

  ## Examples

      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("42.42", currency)
      iex> {:ok, money2} = FinancialSystem.Money.new("10.42", currency)
      iex> {:ok, money3} = FinancialSystem.Money.new("15.42", currency)
      iex> {:ok, from_acc} = FinancialSystem.Account.new(123, money, "Arthur Dent")
      iex> {:ok, to_acc1} = FinancialSystem.Account.new(423, money2, "Ford Prefect")
      iex> {:ok, to_acc2} = FinancialSystem.Account.new(423, money3, "Marvin")
      iex> FinancialSystem.transfer_split(from_acc, [{to_acc1, "0.5"}, {to_acc2, "0.5"}], "15.00")
      {:ok,
      %FinancialSystem.Account{
        balance: %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 2742,
          precision: 2
        },
        number: 123,
        owner: "Arthur Dent"
      },
      [
        %FinancialSystem.Account{
          balance: %FinancialSystem.Money{
            currency: %FinancialSystem.Currency{
              alphabetic_code: "BRL",
              decimal_places: 2,
              numeric_code: 100
            },
            minor_units: 1792,
            precision: 2
          },
          number: 423,
          owner: "Ford Prefect"
        },
        %FinancialSystem.Account{
          balance: %FinancialSystem.Money{
            currency: %FinancialSystem.Currency{
              alphabetic_code: "BRL",
              decimal_places: 2,
              numeric_code: 100
            },
            minor_units: 2292,
            precision: 2
          },
          number: 423,
          owner: "Marvin"
        }
      ]}

  """
  def transfer_split(%Account{} = from_account, accounts_with_percentages, amount)
      when is_list(accounts_with_percentages) do
    Enum.each(accounts_with_percentages, fn {account, _per} = _acc_with_per ->
      if from_account.number == account.number, do: raise("Must transfer to different accounts")

      if from_account.balance.currency != account.balance.currency,
        do: raise("Must convert before transfer to different currencies")
    end)

    if Enum.reduce(accounts_with_percentages, 0.0, fn {_acc, percentage} = _acc_with_per,
                                                      accumulator ->
         String.to_float(percentage) + accumulator
       end) != 1.0,
       do: raise("Percentages must sum 1.0")

    if Account.has_enough_funds?(from_account, amount) do
      {:ok, money_amount} = Money.new(amount, from_account.balance.currency)

      {
        :ok,
        %Account{from_account | balance: Money.subtract(from_account.balance, amount)},
        Enum.map(accounts_with_percentages, fn {account, percentage} = _acc_with_per ->
          %Account{
            account
            | balance: Money.add_money(account.balance, Money.multiply(money_amount, percentage))
          }
        end)
      }
    else
      {:error, "Account does not have enough funds to transfer"}
    end
  end
end
