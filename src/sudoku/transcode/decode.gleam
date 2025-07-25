import gleam/io
import sudoku/state as s

@external(javascript, "./file.ffi.mjs", "read_file")
pub fn read_file(path: String) -> Result(String, Nil) {
  todo
}

pub fn from_file(path: String) -> s.Sudoku {
  todo
}
