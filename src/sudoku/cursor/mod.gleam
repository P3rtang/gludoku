import gleam/int
import sudoku/pos as p

pub type Cursor {
  Cursor(pos: p.Pos, grid: #(Int, Int))
}

pub fn down(cursor: Cursor) -> Cursor {
  let assert Cursor(p.Pos(#(col, row)), #(cols, rows)) = cursor

  Cursor(p.Pos(#(col, int.min(row + 1, rows - 1))), #(cols, rows))
}

pub fn up(cursor: Cursor) -> Cursor {
  let assert Cursor(p.Pos(#(col, row)), #(cols, rows)) = cursor

  Cursor(p.Pos(#(col, int.max(row - 1, 0))), #(cols, rows))
}

pub fn left(cursor: Cursor) -> Cursor {
  let assert Cursor(p.Pos(#(col, row)), #(cols, rows)) = cursor

  Cursor(p.Pos(#(int.max(col - 1, 0), row)), #(cols, rows))
}

pub fn right(cursor: Cursor) -> Cursor {
  let assert Cursor(p.Pos(#(col, row)), #(cols, rows)) = cursor

  Cursor(p.Pos(#(int.min(col + 1, cols - 1), row)), #(cols, rows))
}
