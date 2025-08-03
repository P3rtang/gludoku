import gleam/list
import gleam/result
import sudoku/cell/mod as c
import sudoku/pos
import sudoku/sudoku.{type Sudoku, Sudoku}
import sudoku/utils/index
import sudoku/utils/positions

pub fn get(sudoku: Sudoku, row_index: Int) -> Result(List(c.Cell), Nil) {
  let Sudoku(_, size) = sudoku
  let stride = size.0 * size.1

  use _ <- result.try(case row_index < stride {
    False -> Error(Nil)
    True -> Ok(Nil)
  })

  use position <- list.try_map(
    pos.Index(row_index * 9) |> positions.row(stride),
  )
  sudoku |> index.get(position |> pos.index(stride))
}
