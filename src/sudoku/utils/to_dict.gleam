import gleam/dict
import sudoku/cell/mod.{type Cell}
import sudoku/state as s

pub fn to_dict(sudoku: s.Sudoku) -> dict.Dict(Int, Cell) {
  let s.Sudoku(values, _) = sudoku
  values
}
