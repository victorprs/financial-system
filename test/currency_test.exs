defmodule CurrencyTest do
  use ExUnit.Case
  doctest FinancialSystem.Currency

  test "check valid? against valid currency" do
    assert FinancialSystem.Currency.valid?("BRL", 123, 2) == :ok
  end

  test "check valid? against currency with invalid alpha code" do
    assert_raise RuntimeError, "Invalid alphabetic code", fn ->
      FinancialSystem.Currency.valid?("brl", 123, 2)
    end
  end

  test "check valid? against currency with invalid num code" do
    assert_raise RuntimeError, "Invalid numeric code", fn ->
      FinancialSystem.Currency.valid?("BRL", 1234, 2)
    end
  end

  test "check valid? against currency with invalid decimal places" do
    assert_raise RuntimeError, "Invalid decimal places", fn ->
      FinancialSystem.Currency.valid?("BRL", 123, "a")
    end
  end

  test "check new currency is successfully created" do
    {ok, _currency} = FinancialSystem.Currency.new("BRL", 123, 2)
    assert ok == :ok
  end
end
