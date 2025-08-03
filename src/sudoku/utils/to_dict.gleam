import gleam/dict
import sudoku/cell/mod.{type Cell}
import sudoku/sudoku.{type Sudoku, Sudoku}

pub fn to_dict(sudoku: Sudoku) -> dict.Dict(Int, Cell) {
  let Sudoku(values, _) = sudoku
  values
}
