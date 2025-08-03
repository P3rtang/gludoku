import gleeunit/should
import sudoku/pos.{Pos, coords}

pub fn pos_test() {
  let #(col, row) = Pos(#(4, 5)) |> coords(9)

  should.equal(4, { col / 3 } + { row / 3 } * 3)
}
