defmodule FinancialSystem.Currency do
  @moduledoc """
    Data structure to handle currency operations. 
  """

  defstruct alphabetic_code: nil, numeric_code: nil, decimal_places: nil

  def new(alphabetic_code, numeric_code, decimal_places) do
    case valid?(alphabetic_code, numeric_code, decimal_places) do
      :ok -> {:ok, %FinancialSystem.Currency{
        alphabetic_code: alphabetic_code,
        numeric_code: numeric_code,
        decimal_places: decimal_places}}
    end
  end

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

  def valid_alphabetic_code?(alphabetic_code) do
    case is_binary(alphabetic_code) and String.length(alphabetic_code) == 3 and
           String.match?(alphabetic_code, ~r/[A-Z]{3}/) do
      true -> {:ok, alphabetic_code}
      false -> {:error, "Invalid alphabetic code"}
    end
  end

  def valid_numeric_code?(numeric_code) do
    case is_integer(numeric_code) and numeric_code >= 0 and
           numeric_code < 1000 do
      true -> {:ok, numeric_code}
      false -> {:error, "Invalid numeric code"}
    end
  end
end
