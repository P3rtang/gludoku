import gleam/set
import sudoku/pos as p

pub type Selection =
  set.Set(Int)

pub fn toggle(selection: Selection, pos: p.Pos) -> Selection {
  let cell = pos |> p.index(9)

  case selection |> set.contains(cell) {
    True -> selection |> set.delete(cell)
    False -> selection |> set.insert(cell)
  }
}

pub fn new() -> Selection {
  set.new()
}
