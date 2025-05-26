import gleam/list
import lustre/element.{type Element}
import lustre/element/html

pub type Sudoku =
  List(Cell)

pub fn new() -> Sudoku {
  [
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
  ]
}

pub fn get_cell(sudoku: Sudoku, pos: Pos) -> Cell {
    case pos {
        Index(idx) -> sudoku[idx],
        Pos(#(col, row)) -> sudoku[col + row * 9]
    }
}

pub fn view(_sudoku: Sudoku) -> Element(void) {
  list.range(0, 8) |> list.map(fn (row) {
      list.range(0, 8) |> list.map
  })
}

pub type Pos {
    Index(Int)
    Pos(#(Int, Int))
}

pub type Cell {
  Empty
  Preset(Int)
  Filled(Int)
  Mark(Mark)
}

pub type Mark =
  Int

pub fn mark_value(_mark: Mark) -> List(Int) {
  todo
}
