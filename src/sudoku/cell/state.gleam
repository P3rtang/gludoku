pub type Cell {
  Empty
  Preset(Int)
  Filled(Int)
  Solved(Int)
  Marking(Mark)
}

pub type Model {
  Model(cell: Cell, focus: Bool, selected: Bool)
}

pub type Msg {
  ClickCell
  UpdateValue(Model)
}

pub type Mark {
  Corner(value: Int)
  Center(value: Int)
}
