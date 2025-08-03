import gleam/dict
import sudoku/cell/state.{type Cell, Empty, Marking, Preset}
import sudoku/cursor/mod as cursor
import sudoku/history/history.{type History}
import sudoku/selection.{type Selection}
import sudoku/sudoku.{type Sudoku}

pub type Model {
  Model(
    sudoku: Sudoku,
    cursor: cursor.Cursor,
    selection: Selection,
    history: History,
  )
}

pub type Msg {
  UserPressedKey(KeyEvent)
}

pub type KeyEvent {
  KeyEvent(key: String, code: String, shift: Bool, ctrl: Bool)
}
