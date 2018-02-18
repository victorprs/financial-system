defmodule FinancialSystemTest do
  use ExUnit.Case
  doctest FinancialSystem

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  setup_all do
    currency_brl = %Currency{alphabetic_code: "BRL", numeric_code: 100, decimal_places: 2}
    currency_usd = %Currency{alphabetic_code: "USD", numeric_code: 101, decimal_places: 2}

    {
      :ok,
      [
      currency_brl: currency_brl,
      currency_usd: currency_usd,
      money10_brl: %Money{minor_units: 1000, precision: 2, currency: currency_brl},
      money1050_brl: %Money{minor_units: 1050, precision: 2, currency: currency_brl},
      money1050_precision_brl: %Money{minor_units: 105000, precision: 4, currency: currency_brl},
      money10_usd: %Money{minor_units: 1050, precision: 2, currency: currency_usd}
      ]
    }
  end

  test "convert 10.50 brl to usd with 3.3 exchange_rate", state do
    assert %Money{minor_units: 34650, precision: 3, currency: state[:currency_usd]} == FinancialSystem.convert(state[:money1050_brl], state[:currency_usd], "3.3")
  end

  test "convert 10.50 brl to brl with 3.3 exchange_rate raise_exception", state do
    assert_raise RuntimeError, "Error: same currency conversion", fn ->
      FinancialSystem.convert(state[:money1050_brl], state[:currency_brl], "3.3")
    end
  end
end
