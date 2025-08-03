import gleam/dict
import sudoku/cell/mod.{type Cell}
import sudoku/sudoku.{type Sudoku, Sudoku}

pub fn get(s: Sudoku, idx: Int) -> Result(Cell, Nil) {
  let Sudoku(values, _) = s
  values |> dict.get(idx)
}

pub fn set(s: Sudoku, idx: Int, value: Cell) -> Result(Sudoku, Nil) {
  let Sudoku(values, #(col, row)) = s

  case col * col * row * row > idx {
    True -> Ok(Sudoku(values |> dict.insert(idx, value), #(col, row)))
    False -> Error(Nil)
  }
}
