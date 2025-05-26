import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub type Sudoku =
  dict.Dict(Int, Cell)

pub fn new() -> Sudoku {
  dict.from_list([
    #(0, Empty),
    #(1, Filled(2)),
    #(2, Preset(5)),
    #(3, Empty),
    #(4, Empty),
    #(5, Empty),
    #(6, Empty),
    #(7, Empty),
    #(8, Empty),
    #(9, Empty),
    #(10, Empty),
    #(11, Empty),
    #(12, Empty),
    #(13, Empty),
    #(14, Empty),
    #(15, Empty),
    #(16, Empty),
    #(17, Empty),
    #(18, Empty),
    #(19, Empty),
    #(20, Empty),
    #(21, Empty),
    #(22, Empty),
    #(23, Empty),
    #(24, Empty),
    #(25, Empty),
    #(26, Empty),
    #(27, Empty),
    #(28, Empty),
    #(29, Empty),
    #(30, Empty),
    #(31, Empty),
    #(32, Empty),
    #(33, Empty),
    #(34, Empty),
    #(35, Empty),
    #(36, Empty),
    #(37, Empty),
    #(38, Empty),
    #(39, Empty),
    #(40, Empty),
    #(41, Empty),
    #(42, Empty),
    #(43, Empty),
    #(44, Empty),
    #(45, Empty),
    #(46, Empty),
    #(47, Empty),
    #(48, Empty),
    #(49, Empty),
    #(50, Empty),
    #(51, Empty),
    #(52, Empty),
    #(53, Empty),
    #(54, Empty),
    #(55, Empty),
    #(56, Empty),
    #(57, Empty),
    #(58, Empty),
    #(59, Empty),
    #(60, Empty),
    #(61, Empty),
    #(62, Empty),
    #(63, Empty),
    #(64, Empty),
    #(65, Empty),
    #(66, Empty),
    #(67, Empty),
    #(68, Empty),
    #(69, Empty),
    #(70, Empty),
    #(71, Empty),
    #(72, Empty),
    #(73, Empty),
    #(74, Empty),
    #(75, Empty),
    #(76, Empty),
    #(77, Empty),
    #(78, Empty),
    #(79, Empty),
    #(80, Empty),
  ])
}

pub fn get_cell(sudoku: Sudoku, pos: Pos) -> Result(Cell, Nil) {
  let idx = case pos {
    Index(idx) -> idx
    Pos(#(col, row)) -> col + row * 9
  }

  sudoku |> dict.get(idx)
}

pub fn view(sudoku: Sudoku) -> Element(void) {
  let cell_view =
    {
      use row <- list.try_map(list.range(0, 8))
      use col <- list.try_map(list.range(0, 8))

      use cell <- result.map(sudoku |> get_cell(Pos(#(col, row))))
      cell |> view_cell
    }
    |> result.map(fn(l) {
      l
      |> list.map(fn(l) { html.div([attribute.class("flex flex-row h32")], l) })
    })
    |> result.unwrap([html.div([], [])])

  html.div([], cell_view)
}

pub fn view_cell(cell: Cell) -> Element(void) {
  let #(value, bg) = case cell {
    Empty -> #(None, None)
    Preset(val) -> #(
      Some(val |> int.to_string),
      Some("oklch(92.3% 0.003 48.717)"),
    )
    Filled(val) -> #(Some(val |> int.to_string), None)
    Mark(_) -> todo
  }

  html.div(
    [
      attribute.class(
        "border border-black h-16 w-16 flex items-center justify-center text-4xl",
      ),
      attribute.style("background", bg |> option.unwrap("transparent")),
    ],
    [html.text(value |> option.unwrap(""))],
  )
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
