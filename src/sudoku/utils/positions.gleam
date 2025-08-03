import gleam/list
import sudoku/pos.{type Pos, Pos, coords}

///
/// Returns all positions in the same sudoku box as the given pos
///
pub fn box(pos: Pos, box_size: #(Int, Int)) -> List(Pos) {
  let stride = box_size.0 * box_size.1
  let #(bc_size, br_size) = box_size
  let #(col, row) = pos |> coords(stride)

  let col_floor = { col / bc_size } * bc_size
  let row_floor = { row / br_size } * br_size

  {
    use col_idx <- list.map(list.range(0, bc_size - 1))
    use row_idx <- list.map(list.range(0, br_size - 1))

    Pos(#(col_idx + col_floor, row_idx + row_floor))
  }
  |> list.flatten
}

/// Returns all positions in the same row as the given pos
/// The second argument is used to set the row size
pub fn row(pos: Pos, stride: Int) -> List(Pos) {
  let #(_, row) = pos |> coords(stride)

  use col <- list.map(list.range(0, stride - 1))
  Pos(#(col, row))
}

/// Returns all positions in the same row as the given pos
/// The second argument is used to set the row size
pub fn col(pos: Pos, stride: Int) -> List(Pos) {
  let #(col, _) = pos |> coords(stride)

  use row <- list.map(list.range(0, stride - 1))
  Pos(#(col, row))
}
