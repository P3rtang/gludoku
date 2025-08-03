import gleam/list
import sudoku/cell/mod.{type Cell}
import sudoku/pos
import sudoku/sudoku.{type Sudoku, Sudoku}
import sudoku/utils/index
import sudoku/utils/positions

pub fn get(sudoku: Sudoku, box_index: Int) -> Result(List(Cell), Nil) {
  let Sudoku(_, size) = sudoku
  let stride = size.0 * size.1

  positions.box(pos.Pos(#({ box_index % 3 } * 3, { box_index / 3 } * 3)), size)
  |> list.try_map(fn(p) {
    let idx = pos.index(p, stride)
    sudoku |> index.get(idx)
  })
}
