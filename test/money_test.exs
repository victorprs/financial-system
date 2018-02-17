defmodule MoneyTest do
  use ExUnit.Case
  doctest FinancialSystem.Money

  alias FinancialSystem.Money
  alias FinancialSystem.Currency

  setup_all do
    currency_brl = %Currency{alphabetic_code: "BRL", numeric_code: 100, decimal_places: 2}
    currency_usd = %Currency{alphabetic_code: "USD", numeric_code: 101, decimal_places: 2}
    {
      :ok,
      [
       currency_brl: currency_brl,
       money10_brl: %Money{integer_part: 10, fractional_part: 0, currency: currency_brl},
       money1050_brl: %Money{integer_part: 10, fractional_part: 50, currency: currency_brl},
       money10_usd: %Money{integer_part: 10, fractional_part: 0, currency: currency_usd}
      ]
    }
  end

  test "check valid_amount? against 10 as string" do
    assert Money.valid_amount?("10")
  end

  test "check valid_amount? against 10.5 as string" do
    assert Money.valid_amount?("10.5")
  end

  test "check valid_amount? against alphabetic value" do
    refute Money.valid_amount?("1a")
  end

  test "check valid_amount? against whitespace value" do
    refute Money.valid_amount?(" ")
  end

  test "check valid_amount? against 10 as int" do
    refute Money.valid_amount?(10)
  end

  test "check valid_amount? against 10.5 as float" do
    refute Money.valid_amount?(10.5)
  end

  test "check fractional part from 10.5 and 1 decimal places" do
    assert Money.get_fractional_part("10.5", 1) == 5
  end

  test "check fractional part from 10.5 and 2 decimal places" do
    assert Money.get_fractional_part("10.5", 2) == 50
  end

  test "check fractional part from 10.5 and 3 decimal places" do
    assert Money.get_fractional_part("10.5", 3) == 500
  end

  test "check integer part from 10.5" do
    assert Money.get_integer_part("10.5") == 10
  end

  test "check new money is successfully created", state do
    {ok, _money} = Money.new("10.5", state[:currency_brl])
    assert ok == :ok
  end

  test "check new money with invalid amount", state do
    assert_raise RuntimeError, "Invalid amount format", fn -> 
      Money.new("10 5", state[:currency_brl])
    end
  end

  test "add two moneys 10 + 10.5 = 20.5", state do
    assert %Money{integer_part: 20, fractional_part: 50, currency: state[:currency_brl]} == Money.add(state[:money10_brl], state[:money1050_brl])
  end


  test "add two moneys 10 + 10.5 = 20.5 by value", state do
    assert %Money{integer_part: 20, fractional_part: 50, currency: state[:currency_brl]} == Money.add(state[:money10_brl], "10.5")
  end

  test "add money with different currencies fails", state do
    assert_raise RuntimeError, "Can't add different currencies", fn ->
      Money.add(state[:money10_brl], state[:money10_usd])
    end
  end

  test "subtract two moneys 10.5 - 10 = 0.5", state do
    assert %Money{integer_part: 0, fractional_part: 50, currency: state[:currency_brl]} == Money.subtract(state[:money1050_brl], state[:money10_brl])
  end


  test "subtract two moneys 10.5 + 10 = 0.5 by value", state do
    assert %Money{integer_part: 0, fractional_part: 50, currency: state[:currency_brl]} == Money.subtract(state[:money1050_brl], "10.0")
  end

  test "subtract money with different currencies fails", state do
    assert_raise RuntimeError, "Can't subtract different currencies", fn ->
      Money.subtract(state[:money10_brl], state[:money10_usd])
    end
  end
end