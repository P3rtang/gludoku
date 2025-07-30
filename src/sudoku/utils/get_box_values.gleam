import gleam/list
import sudoku/cell/mod.{type Cell}
import sudoku/generator/mod as g
import sudoku/pos
import sudoku/state.{type Sudoku, Sudoku}
import sudoku/utils/utils

pub fn get(sudoku: Sudoku, box_index: Int) -> Result(List(Cell), Nil) {
  let Sudoku(_, size) = sudoku
  let stride = size.0 * size.1

  g.box_positions(
    pos.Pos(#({ box_index % 3 } * 3, { box_index / 3 } * 3)),
    size,
  )
  |> list.try_map(fn(p) {
    let idx = pos.index(p, stride)
    sudoku |> utils.get_index(idx)
  })
}
