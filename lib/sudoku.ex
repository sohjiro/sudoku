defmodule Sudoku do
  @moduledoc """
  Documentation for Sudoku.
  """

  def eval_from_file(filepath) do
    filepath
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&eval/1)
  end

  def eval(text) do
    text
    |> fetch_size_and_values()
    |> sudoku_valid?()
  end

  def fetch_size_and_values(text) do
    [size, values] = String.split(text, ";", trim: true)
    {parse(size), values}
  end

  defp sudoku_valid?({size, values}) do
    case validate_sudoku(size, values) do
      {true, true, true, _board} ->
        true
      _ ->
        false
    end
  end

  defp validate_sudoku(size, values) do
    board = board(size, values)

    row = valid_rows?(board)

    col =
      board
      |> transpose()
      |> valid_rows?()

    blocks =
      size
      |> quadrants()
      |> to_blocks(board)
      |> valid_rows?()

    {row, col, blocks, board}
  end

  defp generate_coordinates(blocks) do
    Enum.map(blocks, fn({q_x, q_y}) ->
      for x <- q_x, y <- q_y, do: {x, y}
    end)
  end

  defp to_blocks(blocks, board) do
    blocks
    |> generate_coordinates()
    |> Enum.map(&(extract_values_from_coordinates(&1, board)))
  end

  defp extract_values_from_coordinates(row_coordinates, board) do
    Enum.map(row_coordinates, fn({x, y}) ->
      board
      |> Enum.at(x)
      |> Enum.at(y)
    end)
  end

  defp quadrants(size) do
    quadrant_size = floor(:math.sqrt(size))
    quadrant_total = 0..(size-1)

    for block <- quadrant_total do
      q_x = div(block, quadrant_size) * quadrant_size
      q_y = rem(block, quadrant_size) * quadrant_size
      {q_x..(q_x + quadrant_size - 1), q_y..(q_y + quadrant_size - 1)}
    end
  end

  defp valid_rows?(board) do
    1 ===
    board
    |> Enum.flat_map(&frequencies/1)
    |> Enum.uniq()
    |> length()
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

  defp parse(size) do
    String.to_integer(size)
  end

  defp frequencies(row) do
    row
    |> Enum.reduce(%{}, fn(data, acc) ->
      Map.update(acc, data, 1, &(&1 + 1))
    end)
    |> Map.values()
    |> Enum.uniq()
  end
end
