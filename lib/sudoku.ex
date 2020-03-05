defmodule Sudoku do
  @moduledoc """
  Documentation for Sudoku.
  """

  def eval_from_file(filepath) do
    filepath
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def eval(text) do
    text
    |> fetch_size_and_values()
    |> valid_input?()
  end

  def fetch_size_and_values(text) do
    [size, values] = String.split(text, ";", trim: true)
    {parse(size), values}
  end

  defp valid_input?({size, values}) do
    rows = board(size, values)
    cols = transpose(rows)

    rows
    |> concat_rows_and_columns(cols)
    |> valid?(size)
  end

  defp board(size, values) do
    values
    |> String.split(",", trim: true)
    |> Enum.chunk_every(size)
  end

  defp transpose(board) do
    board
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp concat_rows_and_columns(rows, cols) do
    List.zip(rows ++ cols)
  end

  defp parse(size) do
    String.to_integer(size)
  end

  defp valid?(rows, _size) do
    rows
    |> fetch_frequencies()
    |> valid_frequencies()
  end

  defp fetch_frequencies(rows) do
    Enum.reduce(rows, [], &([frequencies(&1) | &2]))
  end

  defp frequencies(row) do
    row
    |> Tuple.to_list()
    |> Enum.reduce(%{}, fn(data, acc) ->
      Map.update(acc, data, 1, &(&1 + 1))
    end)
  end

  defp valid_frequencies(frequencies) do
    frequencies
    |> Enum.map(fn(row) ->
      row
      |> Map.values()
      |> Enum.all?(&(&1 === 2))
    end)
    |> Enum.all?()
  end
end
