import sudoku/cursor/mod as cursor
import sudoku/history/history.{type History}
import sudoku/input_mode/input_mode.{type InputMode, type KeyEvent}
import sudoku/selection.{type Selection}
import sudoku/sudoku.{type Sudoku}

pub type Model {
  Model(
    sudoku: Sudoku,
    cursor: cursor.Cursor,
    selection: Selection,
    history: History,
    input: InputMode(Model),
  )
}

pub type Msg {
  UserPressedKey(KeyEvent)
}
