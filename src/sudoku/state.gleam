import gleam/dict
import sudoku/cell/state.{type Cell, Empty, Marking, Preset}
import sudoku/cursor/mod as cursor
import sudoku/selection.{type Selection}

pub type Model {
  Model(sudoku: Sudoku, cursor: cursor.Cursor, selection: Selection)
}

pub type Msg {
  UserPressedKey(KeyEvent)
}

pub type KeyEvent {
  KeyEvent(key: String, code: String, shift: Bool, ctrl: Bool)
}

pub type Sudoku {

  Sudoku(values: dict.Dict(Int, Cell), size: #(Int, Int))
}

pub fn new() -> Sudoku {
  Sudoku(
    dict.from_list([
      #(0, Empty),
      #(1, Preset(5)),
      #(2, Preset(3)),
      #(3, Preset(8)),
      #(4, Marking(state.Corner(0b00010011))),
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
    ]),
    #(3, 3),
  )
}
