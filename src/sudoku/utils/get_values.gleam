import gleam/list
import gleam/option
import gleam/result
import sudoku/cell/cell as c
import sudoku/state as s
import sudoku/utils/utils

pub fn get_values(
  sudoku: s.Sudoku,
  indeces: List(Int),
) -> Result(List(Int), Nil) {
  use idx <- list.try_map(indeces)
  use cell <- result.try(sudoku |> utils.get_index(idx))
  cell |> c.value |> option.to_result(Nil)
}
