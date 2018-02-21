defmodule FinancialSystemTest do
  use ExUnit.Case
  doctest FinancialSystem

  alias FinancialSystem.Currency
  alias FinancialSystem.Money
  alias FinancialSystem.Account

  setup_all do
    currency_brl = %Currency{alphabetic_code: "BRL", numeric_code: 100, decimal_places: 2}
    currency_usd = %Currency{alphabetic_code: "USD", numeric_code: 101, decimal_places: 2}
    money1050_brl = %Money{minor_units: 1050, precision: 2, currency: currency_brl}
    money10_brl = %Money{minor_units: 1000, precision: 2, currency: currency_brl}
    money10_usd = %Money{minor_units: 1050, precision: 2, currency: currency_usd}
    money950_brl = %Money{minor_units: 950, precision: 2, currency: currency_brl}

    {
      :ok,
      [
        currency_brl: currency_brl,
        currency_usd: currency_usd,
        money10_brl: money10_brl,
        money1050_brl: money1050_brl,
        money950_brl: money950_brl,
        money1050_precision_brl: %Money{
          minor_units: 105_000,
          precision: 4,
          currency: currency_brl
        },
        money10_usd: money10_usd,
        account1050_brl: %Account{number: 123, balance: money1050_brl, owner: "Arthur Dent"},
        account10_brl: %Account{number: 456, balance: money10_brl, owner: "Ford Prefect"},
        account10_usd: %Account{number: 243, balance: money10_usd, owner: "Marvin"},
        account950_brl: %Account{number: 245, balance: money950_brl, owner: "Marvin"}
      ]
    }
  end

  test "convert 10.50 brl to usd with 3.3 exchange_rate", state do
    assert %Money{minor_units: 34650, precision: 3, currency: state[:currency_usd]} ==
             FinancialSystem.convert(state[:money1050_brl], state[:currency_usd], "3.3")
  end

  test "convert 10.50 brl to brl with 3.3 exchange_rate raise_exception", state do
    assert_raise RuntimeError, "Error: same currency conversion", fn ->
      FinancialSystem.convert(state[:money1050_brl], state[:currency_brl], "3.3")
    end
  end

  test "withdraw 13.37 from an account with 10.50 balance", state do
    assert {:error, "Account does not have enough funds to withdraw"} ==
             FinancialSystem.withdraw(state[:account1050_brl], "13.37")
  end

  test "withdraw 10.00 from an account with 10.50 balance", state do
    assert {:ok,
            %Account{
              state[:account1050_brl]
              | balance: %Money{state[:money1050_brl] | minor_units: 50}
            }} == FinancialSystem.withdraw(state[:account1050_brl], "10.00")
  end

  test "deposit 10.00 to an account with 10.50 balance", state do
    assert {:ok,
            %Account{
              state[:account1050_brl]
              | balance: %Money{state[:money1050_brl] | minor_units: 2050}
            }} == FinancialSystem.deposit(state[:account1050_brl], "10.00")
  end

  test "raises an exception if transfer between account with different currencies", state do
    assert_raise RuntimeError, fn ->
      FinancialSystem.transfer(state[:account1050_brl], state[:account10_usd], "10.00")
    end
  end

  test "User should be able to transfer money to another account", state do
    assert {
             :ok,
             %Account{
               state[:account1050_brl]
               | balance: %Money{state[:money1050_brl] | minor_units: 550}
             },
             %Account{
               state[:account10_brl]
               | balance: %Money{state[:money10_brl] | minor_units: 1500}
             }
           } == FinancialSystem.transfer(state[:account1050_brl], state[:account10_brl], "5.00")
  end

  test "User cannot transfer if not enough money available on the account", state do
    assert {:error, "Account does not have enough funds to transfer"} ==
             FinancialSystem.transfer(state[:account1050_brl], state[:account10_brl], "50.00")
  end

  test "A transfer should be cancelled if an error occurs", state do
    assert_raise RuntimeError, fn ->
      FinancialSystem.transfer(state[:account1050_brl], state[:account1050_brl], "10.00")
    end
  end

  test "A transfer can be splitted between 2 or more accounts", state do
    assert {:ok,
            %Account{
              state[:account1050_brl]
              | balance: %Money{state[:money1050_brl] | minor_units: 500}
            },
            [
              %Account{
                state[:account10_brl]
                | balance: %Money{state[:money10_brl] | minor_units: 12750, precision: 3}
              },
              %Account{
                state[:account950_brl]
                | balance: %Money{state[:money950_brl] | minor_units: 12250, precision: 3}
              }
            ]} ==
             FinancialSystem.transfer_split(
               state[:account1050_brl],
               [{state[:account10_brl], "0.5"}, {state[:account950_brl], "0.5"}],
               "5.50"
             )
  end

  test "transfer split raises error with different currencies", state do
    assert_raise RuntimeError, fn ->
      FinancialSystem.transfer_split(
        state[:account1050_brl],
        [{state[:account10_brl], "0.5"}, {state[:account10_usd], "0.5"}],
        "5.50"
      )
    end
  end

  test "transfer split raises error with sum of percentages different than 1.0", state do
    assert_raise RuntimeError, fn ->
      FinancialSystem.transfer_split(
        state[:account1050_brl],
        [{state[:account10_brl], "0.5"}, {state[:account950_brl], "0.4"}],
        "5.50"
      )
    end
  end
end
