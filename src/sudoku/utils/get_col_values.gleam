import gleam/list
import gleam/result
import sudoku/cell/mod as c
import sudoku/generator/mod
import sudoku/pos
import sudoku/state.{type Sudoku, Sudoku}
import sudoku/utils/utils

pub fn get(sudoku: Sudoku, col_index: Int) -> Result(List(c.Cell), Nil) {
  let Sudoku(_, size) = sudoku
  let stride = size.0 * size.1

  use _ <- result.try(case col_index < stride {
    False -> Error(Nil)
    True -> Ok(Nil)
  })

  use position <- list.try_map(
    pos.Index(col_index) |> mod.col_positions(stride),
  )
  sudoku |> utils.get_index(position |> pos.index(stride))
}
