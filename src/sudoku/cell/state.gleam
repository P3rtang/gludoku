import sudoku/input_mode/input_mode

pub type Cell {
  Empty
  Preset(Int)
  Filled(Int)
  Solved(Int)
  Marking(Mark)
}

pub type Model {
  Model(cell: Cell, focus: Bool, selected: Bool, mode: input_mode.Mode)
}

pub type Msg {
  ClickCell
  UpdateValue(Model)
}

pub type Mark {
  Mark(corner: Int, center: Int)
}
