defmodule FinancialSystem.Currency do
  @moduledoc """
    Data structure to handle currency operations. All inputed currencies must 
    be in compliance with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217).
  """

  alias FinancialSystem.Currency

  defstruct alphabetic_code: nil, numeric_code: nil, decimal_places: nil

  @doc """
    Creates a new currency with its respective alphabetic code, numeric code
    and decimal places. 

    If successfull, returns a tuple with `:ok` status and the created
    `FinancialSystem.Currency`.
    Otherwise, raises a `RuntimeError` when the currency is not valid
  ## Examples

      iex> FinancialSystem.Currency.new("BRL", 100, 2)
      {:ok,
        %FinancialSystem.Currency{
          alphabetic_code: "BRL",
          decimal_places: 2,
          numeric_code: 100
        }}

  """
  def new(alphabetic_code, numeric_code, decimal_places) do
    case valid?(alphabetic_code, numeric_code, decimal_places) do
      :ok ->
        {:ok,
         %Currency{
           alphabetic_code: alphabetic_code,
           numeric_code: numeric_code,
           decimal_places: decimal_places
         }}
    end
  end

  @doc """
    Checks if the given `currency` is valid

    Returns `:ok` if successfull. Raises a `RuntimeError` when the currency is not valid.
  ## Examples

      iex> cur1 = %FinancialSystem.Currency{alphabetic_code: "BRL", numeric_code: 100, decimal_places: 2}
      iex> FinancialSystem.Currency.valid?(cur1)
      :ok
  """
  def valid?(%Currency{} = currency) do
    valid?(
      currency.alphabetic_code,
      currency.numeric_code,
      currency.decimal_places
    )
  end

  @doc """
    Checks if the alphabetic code, numeric code and decimal places are valid.

    Returns `:ok` if successfull. Raises a `RuntimeError` when the currency is not valid.

  ## Examples

      iex> FinancialSystem.Currency.valid?("BRL", 100, 2)
      :ok
  """
  def valid?(alphabetic_code, numeric_code, decimal_places) do
    case valid_alphabetic_code?(alphabetic_code) do
      {:ok, _} -> nil
      {:error, err} -> raise err
    end

    case valid_numeric_code?(numeric_code) do
      {:ok, _} -> nil
      {:error, err} -> raise err
    end

    if !is_integer(decimal_places) or decimal_places < 0 do
      raise "Invalid decimal places"
    end

    :ok
  end

  @doc """
    Checks if the alphabetic code is valid.

    Returns a tuple with status `:ok` and the given code if successfull.
    Otherwise, returns a tuple with status `:error` and the error message.
  ## Examples

      iex> FinancialSystem.Currency.valid_alphabetic_code?("BRL")
      {:ok, "BRL"}
  """
  def valid_alphabetic_code?(alphabetic_code) do
    case is_binary(alphabetic_code) and String.length(alphabetic_code) == 3 and
           String.match?(alphabetic_code, ~r/[A-Z]{3}/) do
      true -> {:ok, alphabetic_code}
      false -> {:error, "Invalid alphabetic code"}
    end
  end

  @doc """
    Checks if the numeric code is valid.

    Returns a tuple with status `:ok` and the given code if successfull.
    Otherwise, returns a tuple with status `:error` and the error message.
  ## Examples

      iex> FinancialSystem.Currency.valid_numeric_code?(100)
      {:ok, 100}
  """
  def valid_numeric_code?(numeric_code) do
    case is_integer(numeric_code) and numeric_code >= 0 and numeric_code < 1000 do
      true -> {:ok, numeric_code}
      false -> {:error, "Invalid numeric code"}
    end
  end
end
