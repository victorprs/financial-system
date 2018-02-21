defmodule FinancialSystem.Money do
  @moduledoc """
    Data structure to handle money operations. It takes advantage of Elixir's
    bignum arithmetics with the basic type `integer` to store the minor units
    of a money value given its currency.
  """

  defstruct minor_units: nil, precision: nil, currency: nil

  alias FinancialSystem.Currency
  alias FinancialSystem.Money

  @doc """
    Creates a new money with the `amount` given in a string format, a default
    precision of 2 in its minor units and a given `currency`.

    If successfull, returns a tuple with `:ok` status and the created
    `FinancialSystem.Money`.
    Otherwise, raises a `RuntimeError` when the amount is not valid
  ## Examples

      iex> {:ok, currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> FinancialSystem.Money.new("13.37", currency)
      {:ok,
        %FinancialSystem.Money{
          currency: %FinancialSystem.Currency{
            alphabetic_code: "BRL",
            decimal_places: 2,
            numeric_code: 100
          },
          minor_units: 1337,
          precision: 2
        }}
      
  """
  def new(amount, precision \\ 2, %Currency{} = currency) do
    if not valid_amount?(amount) do
      raise "Invalid amount format"
    end

    {:ok,
     %Money{
       minor_units: string_to_minor_units(amount, precision),
       precision: precision,
       currency: currency
     }}
  end

  @doc """
    Check validity of given amount. 

    Returns `true` if valid, `false` otherwise

  ## Examples

      iex> FinancialSystem.Money.valid_amount?("13.37")
      true
  """
  def valid_amount?(amount) when is_binary(amount) do
    try do
      _ = String.to_float(amount)
      true
    rescue
      ArgumentError -> false
    end
  end

  def valid_amount?(amount) when is_number(amount), do: false

  @doc """
    Parse a given amount in the string format to the money's structure
    compatible minor units. `decimal_places` is the desired precision

    Returns the parsed minor units.
  ## Examples

      iex> FinancialSystem.Money.string_to_minor_units("13.37", 2)
      1337
  """
  def string_to_minor_units(amount, decimal_places) do
    {int_part, tail} = Integer.parse(amount)

    fract_part =
      tail
      |> String.trim(".")
      |> String.pad_trailing(decimal_places, "0")
      |> String.to_integer()

    int_part * power_of_ten(decimal_places) + fract_part
  end

  @doc """
    Addition operation. Adds a given `value` in the string format to the given
    money. 

    Returns a new `FinancialSystem.Money`. Raises an error if different 
    currencies.

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("13.37", original_currency)
      iex> FinancialSystem.Money.add(money, "6.16")
      %FinancialSystem.Money{
        currency: %FinancialSystem.Currency{
          alphabetic_code: "BRL",
          decimal_places: 2,
          numeric_code: 100
        },
        minor_units: 1953,
        precision: 2
      }
  """
  def add(%Money{} = money1, value) when is_binary(value) do
    {:ok, money2} = Money.new(value, money1.precision, money1.currency)
    add_money(money1, money2)
  end

  @doc """
    Addition operation. Adds `money2` to `money1`. 

    Returns a new `FinancialSystem.Money`. Raises an error if different 
    currencies.

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money1} = FinancialSystem.Money.new("13.37", original_currency)
      iex> {:ok, money2} = FinancialSystem.Money.new("6.16", original_currency)
      iex> FinancialSystem.Money.add_money(money1, money2)
      %FinancialSystem.Money{
        currency: %FinancialSystem.Currency{
          alphabetic_code: "BRL",
          decimal_places: 2,
          numeric_code: 100
        },
        minor_units: 1953,
        precision: 2
      }
  """
  def add_money(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise("Can't add different currencies")

    total =
      cond do
        money1.precision == money2.precision ->
          money1.minor_units + money2.minor_units

        money1.precision > money2.precision ->
          money1.minor_units +
            money2.minor_units * power_of_ten(money1.precision - money2.precision)

        money1.precision < money2.precision ->
          money1.minor_units * power_of_ten(money2.precision - money1.precision) +
            money2.minor_units
      end

    %Money{
      minor_units: total,
      precision: max(money1.precision, money2.precision),
      currency: money1.currency
    }
  end

  @doc """
    Subtraction operation. Subtracts a given `value` in the string format from
    the given money. 

    Returns a new `FinancialSystem.Money`. Raises an error if different 
    currencies.

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("13.37", original_currency)
      iex> FinancialSystem.Money.subtract(money, "6.16")
      %FinancialSystem.Money{
        currency: %FinancialSystem.Currency{
          alphabetic_code: "BRL",
          decimal_places: 2,
          numeric_code: 100
        },
        minor_units: 721,
        precision: 2
      }
  """
  def subtract(%Money{} = money1, value) when is_binary(value) do
    {:ok, money2} = Money.new(value, money1.precision, money1.currency)
    subtract_money(money1, money2)
  end

  @doc """
    Subtraction operation. Subtracts the `money2` from the `money1`.

    Returns a new `FinancialSystem.Money`. Raises an error if different 
    currencies.

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money1} = FinancialSystem.Money.new("13.37", original_currency)
      iex> {:ok, money2} = FinancialSystem.Money.new("6.16", original_currency)
      iex> FinancialSystem.Money.subtract_money(money1, money2)
      %FinancialSystem.Money{
        currency: %FinancialSystem.Currency{
          alphabetic_code: "BRL",
          decimal_places: 2,
          numeric_code: 100
        },
        minor_units: 721,
        precision: 2
      }
  """
  def subtract_money(%Money{} = money1, %Money{} = money2) do
    if money1.currency != money2.currency, do: raise("Can't subtract different currencies")

    total =
      cond do
        money1.precision == money2.precision ->
          money1.minor_units - money2.minor_units

        money1.precision > money2.precision ->
          money1.minor_units -
            money2.minor_units * power_of_ten(money1.precision - money2.precision)

        money1.precision < money2.precision ->
          money1.minor_units * power_of_ten(money2.precision - money1.precision) -
            money2.minor_units
      end

    %Money{
      minor_units: total,
      precision: max(money1.precision, money2.precision),
      currency: money1.currency
    }
  end

  @doc """
    Multiplication operation. Multiply value of money by a given `value`
    in the string format. 

    Returns a new `FinancialSystem.Money`.

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("13.37", original_currency)
      iex> FinancialSystem.Money.multiply(money, "6.16")
      %FinancialSystem.Money{
        currency: %FinancialSystem.Currency{
          alphabetic_code: "BRL",
          decimal_places: 2,
          numeric_code: 100
        },
        minor_units: 823592,
        precision: 4
      }
  """
  def multiply(%Money{} = money, value) when is_binary(value) do
    if not valid_amount?(value), do: raise("Invalid value format")

    value_precision =
      value
      |> String.split(".")
      |> List.last()
      |> String.length()

    %Money{
      minor_units: money.minor_units * string_to_minor_units(value, value_precision),
      precision: money.precision + value_precision,
      currency: money.currency
    }
  end

  @doc """
    Formats the money in a string.

  ## Examples

      iex> {:ok, original_currency} = FinancialSystem.Currency.new("BRL", 100, 2)
      iex> {:ok, money} = FinancialSystem.Money.new("13.37", original_currency)
      iex> FinancialSystem.Money.as_string(money)
      "13.37"
  """
  def as_string(%Money{} = money) do
    int_part = Integer.to_string(div(money.minor_units, power_of_ten(money.precision)))
    String.replace_prefix(Integer.to_string(money.minor_units), int_part, int_part <> ".")
  end

  defp power_of_ten(n) when n == 0 do
    1
  end

  defp power_of_ten(n) do
    10 * power_of_ten(n - 1)
  end
end
