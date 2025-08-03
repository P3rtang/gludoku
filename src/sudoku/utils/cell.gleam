import gleam/dict
import gleam/result
import sudoku/cell/mod.{type Cell}
import sudoku/cell/state.{Empty, Preset}
import sudoku/pos.{type Pos}
import sudoku/sudoku.{type Sudoku, Sudoku}
import sudoku/utils/index

pub fn get(sudoku: Sudoku, pos: Pos) -> Result(Cell, Nil) {
  let Sudoku(values, size) = sudoku
  let idx = pos |> pos.index(size.0 * size.1)

  values |> dict.get(idx)
}

pub fn set(sudoku: Sudoku, pos: Pos, value: Cell) -> Sudoku {
  let Sudoku(_, size) = sudoku
  let idx = pos |> pos.index(size.0 * size.1)

  {
    use cell <- result.try(case sudoku |> index.get(idx) {
      Ok(Preset(_)) -> Error(Nil)
      Error(_) -> Error(Nil)
      Ok(v) -> Ok(v)
    })

    case cell == value {
      True -> sudoku |> index.set(idx, Empty)
      False -> sudoku |> index.set(idx, value)
    }
  }
  |> result.unwrap(sudoku)
}

pub fn force(sudoku: Sudoku, pos: Pos, value: Cell) -> Sudoku {
  let Sudoku(values, size) = sudoku
  let idx = pos |> pos.index(size.0 * size.1)
  Sudoku(values |> dict.insert(idx, value), size)
}
