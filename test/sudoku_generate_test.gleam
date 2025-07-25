import gleeunit
import gleeunit/should
import sudoku/generator/mod
import sudoku/pos as p

pub fn main() {
  gleeunit.main()
}

pub fn box_values_test() -> Result(Nil, Nil) {
  mod.box_positions(p.Pos(#(0, 0)), #(3, 3), 9)
  |> should.equal([
    p.Pos(#(0, 0)),
    p.Pos(#(0, 1)),
    p.Pos(#(0, 2)),
    p.Pos(#(1, 0)),
    p.Pos(#(1, 1)),
    p.Pos(#(1, 2)),
    p.Pos(#(2, 0)),
    p.Pos(#(2, 1)),
    p.Pos(#(2, 2)),
  ])

  mod.box_positions(p.Pos(#(4, 8)), #(3, 3), 9)
  |> should.equal([
    p.Pos(#(3, 6)),
    p.Pos(#(3, 7)),
    p.Pos(#(3, 8)),
    p.Pos(#(4, 6)),
    p.Pos(#(4, 7)),
    p.Pos(#(4, 8)),
    p.Pos(#(5, 6)),
    p.Pos(#(5, 7)),
    p.Pos(#(5, 8)),
  ])

  mod.box_positions(p.Pos(#(4, 8)), #(2, 3), 9)
  |> should.equal([
    p.Pos(#(4, 6)),
    p.Pos(#(4, 7)),
    p.Pos(#(4, 8)),
    p.Pos(#(5, 6)),
    p.Pos(#(5, 7)),
    p.Pos(#(5, 8)),
  ])

  Ok(Nil)
}

pub fn row_values_test() -> Result(Nil, Nil) {
  mod.row_positions(p.Pos(#(8, 0)), 9, 9)
  |> should.equal([
    p.Pos(#(0, 0)),
    p.Pos(#(1, 0)),
    p.Pos(#(2, 0)),
    p.Pos(#(3, 0)),
    p.Pos(#(4, 0)),
    p.Pos(#(5, 0)),
    p.Pos(#(6, 0)),
    p.Pos(#(7, 0)),
    p.Pos(#(8, 0)),
  ])

  mod.row_positions(p.Pos(#(2, 8)), 5, 9)
  |> should.equal([
    p.Pos(#(0, 8)),
    p.Pos(#(1, 8)),
    p.Pos(#(2, 8)),
    p.Pos(#(3, 8)),
    p.Pos(#(4, 8)),
  ])

  Ok(Nil)
}

pub fn col_values_test() -> Result(Nil, Nil) {
  mod.col_positions(p.Pos(#(8, 0)), 9, 9)
  |> should.equal([
    p.Pos(#(8, 0)),
    p.Pos(#(8, 1)),
    p.Pos(#(8, 2)),
    p.Pos(#(8, 3)),
    p.Pos(#(8, 4)),
    p.Pos(#(8, 5)),
    p.Pos(#(8, 6)),
    p.Pos(#(8, 7)),
    p.Pos(#(8, 8)),
  ])

  mod.col_positions(p.Pos(#(2, 8)), 5, 9)
  |> should.equal([
    p.Pos(#(2, 0)),
    p.Pos(#(2, 1)),
    p.Pos(#(2, 2)),
    p.Pos(#(2, 3)),
    p.Pos(#(2, 4)),
  ])

  Ok(Nil)
}
