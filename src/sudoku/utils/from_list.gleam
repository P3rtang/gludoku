import gleam/dict
import gleam/list
import sudoku/cell/state as cs
import sudoku/state as s

pub fn from_list(l: List(Int), size: #(Int, Int)) -> Result(s.Sudoku, Nil) {
  let #(col, row) = size
  case l |> list.length != col * col * row * row {
    True -> Error(Nil)
    False -> {
      l
      |> list.zip(list.range(0, col * col * row * row))
      |> list.map(fn(zip) {
        let #(val, idx) = zip
        case val {
          0 -> #(idx, cs.Empty)
          _ -> #(idx, cs.Preset(val))
        }
      })
      |> dict.from_list
      |> s.Sudoku(size)
      |> Ok
    }
  }
}
