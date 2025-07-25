pub type Pos {
  Index(Int)
  Pos(#(Int, Int))
}

pub fn index(pos: Pos, stride: Int) -> Int {
  case pos {
    Index(idx) -> idx
    Pos(#(col, row)) -> col + row * stride
  }
}

pub fn coords(pos: Pos, stride: Int) -> #(Int, Int) {
  let idx = pos |> index(stride)
  #(idx % 9, idx / 9)
}
