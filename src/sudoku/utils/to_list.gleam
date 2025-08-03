import gleam/dict
import gleam/list
import gleam/option
import sudoku/cell/cell as c
import sudoku/sudoku.{type Sudoku, Sudoku}

pub fn to_list(sudoku: Sudoku) -> List(Int) {
  let Sudoku(values, _) = sudoku
  use #(_, cell) <- list.map(values |> dict.to_list)
  cell |> c.value |> option.unwrap(0)
}
