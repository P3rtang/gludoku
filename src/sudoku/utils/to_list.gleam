import gleam/dict
import gleam/list
import gleam/option
import sudoku/cell/cell as c
import sudoku/state as s

pub fn to_list(sudoku: s.Sudoku) -> List(Int) {
  let s.Sudoku(values, _) = sudoku
  use #(_, cell) <- list.map(values |> dict.to_list)
  cell |> c.value |> option.unwrap(0)
}
