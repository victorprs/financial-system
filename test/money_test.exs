defmodule MoneyTest do
  use ExUnit.Case
  doctest FinancialSystem.Money

  alias FinancialSystem.Money
  alias FinancialSystem.Currency

  setup_all do
    {
      :ok,
       currency1: %Currency{alphabetic_code: "BRL", numeric_code: 100, decimal_places: 3}
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
    {ok, _money} = Money.new("10.5", state[:currency1])
    assert ok == :ok
  end

  test "check new money with invalid amount", state do
    assert_raise RuntimeError, "Invalid amount format", fn -> 
      Money.new("10 5", state[:currency1])
    end
  end
end