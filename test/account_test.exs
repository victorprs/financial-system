defmodule AccountTest do
  use ExUnit.Case
  doctest FinancialSystem.Account

  alias FinancialSystem.Currency
  alias FinancialSystem.Money
  alias FinancialSystem.Account

  setup_all do
    currency_brl = %Currency{alphabetic_code: "BRL", numeric_code: 100, decimal_places: 2}
    invalid_currency = %Currency{alphabetic_code: "BRL", numeric_code: 1000, decimal_places: 2}
    money4242_brl = %Money{minor_units: 4242, precision: 2, currency: currency_brl}
    invalid_money = %Money{minor_units: 4242, precision: 2, currency: invalid_currency}

    {
      :ok,
      [
        money4242_brl: money4242_brl,
        invalid_money: invalid_money
      ]
    }
  end


  test "creates a new account returns ok", state do
    {ok, _} = Account.new(123, state[:money4242_brl], "Arthur Dent")
    assert ok == :ok
  end

  test "create account with invalid currency raises error", state do
    assert_raise RuntimeError, fn -> 
      Account.new(123, state[:invalid_money], "Arthur Dent")
    end
  end

  test "confirms that balance of 42.42 has enough funds for 42.00 withdraw", state do
    acc = %Account{number: 123, balance: state[:money4242_brl], owner: "Arthur Dent"}
    assert Account.has_enough_funds?(acc, "42.00")
  end

  test "confirms that balance of 42.42 has enough funds for 42.42 withdraw", state do
    acc = %Account{number: 123, balance: state[:money4242_brl], owner: "Arthur Dent"}
    assert Account.has_enough_funds?(acc, "42.42")
  end

  test "confirms of 42.42 has not enough funds for 43.00 withdraw", state do
    acc = %Account{number: 123, balance: state[:money4242_brl], owner: "Arthur Dent"}
    refute Account.has_enough_funds?(acc, "43.00")
  end

  test "raises error if invalid amount given to check if there's funds", state do
    acc = %Account{number: 123, balance: state[:money4242_brl], owner: "Arthur Dent"}
    assert_raise RuntimeError, "Invalid amount format", fn -> 
      Account.has_enough_funds?(acc, "42 42")
    end
  end

end