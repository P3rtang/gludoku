import gleam/bit_array
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import sudoku/cell/cell
import sudoku/cell/state as cs
import sudoku/pos as p
import sudoku/state.{type Sudoku, new}
import sudoku/utils/utils

const default_mod = 0x80000000

// 2 ** 31

pub fn generate(seed: String) -> Result(Sudoku, Nil) {
  use val <- result.map(
    seed
    |> bit_array.from_string
    |> bit_array.base16_encode()
    |> int.base_parse(16),
  )
  echo val

  new()
}

pub fn lcg_with_mod(seed: Int, modulus: Int) -> Int {
  { seed * 22_695_477 + 1 } % modulus
}

pub fn lcg(seed: Int) -> Int {
  lcg_with_mod(seed, default_mod)
}

pub fn solve(sudoku: Sudoku) -> Sudoku {
  solve_with_seed(sudoku, 42)
}

pub fn solve_with_seed(_sudoku: Sudoku, seed: Int) -> Sudoku {
  let _rand = lcg(seed)

  todo
}

pub fn is_valid(sudoku: Sudoku) -> Bool {
  {
    use #(idx, val) <- list.map(sudoku |> utils.to_dict |> dict.to_list)
    let box = verify_idx_list(sudoku, box_positions(p.Index(idx), #(3, 3)), val)
    let row = verify_idx_list(sudoku, row_positions(p.Index(idx), 9), val)
    let col = verify_idx_list(sudoku, col_positions(p.Index(idx), 9), val)
    box && row && col
  }
  |> list.fold(True, fn(acc, b) { acc && b })
}

fn verify_idx_list(sudoku: Sudoku, list: List(p.Pos), val: cs.Cell) -> Bool {
  list
  |> list.map(fn(pos) { sudoku |> utils.get_index(pos |> p.index(9)) })
  |> list.filter_map(fn(cell) { cell })
  |> list.fold(True, fn(b, cell) {
    b && { cell |> cell.value != val |> cell.value }
  })
}

///
/// Returns all positions in the same sudoku box as the given pos
///
pub fn box_positions(pos: p.Pos, box_size: #(Int, Int)) -> List(p.Pos) {
  let stride = box_size.0 * box_size.1
  let #(bc_size, br_size) = box_size
  let #(col, row) = pos |> p.coords(stride)

  let col_floor = { col / bc_size } * bc_size
  let row_floor = { row / br_size } * br_size

  {
    use col_idx <- list.map(list.range(0, bc_size - 1))
    use row_idx <- list.map(list.range(0, br_size - 1))

    p.Pos(#(col_idx + col_floor, row_idx + row_floor))
  }
  |> list.flatten
}

/// Returns all positions in the same row as the given pos
/// The second argument is used to set the row size
pub fn row_positions(pos: p.Pos, stride: Int) -> List(p.Pos) {
  let #(_, row) = pos |> p.coords(stride)

  use col <- list.map(list.range(0, stride - 1))
  p.Pos(#(col, row))
}

/// Returns all positions in the same row as the given pos
/// The second argument is used to set the row size
pub fn col_positions(pos: p.Pos, stride: Int) -> List(p.Pos) {
  let #(col, _) = pos |> p.coords(stride)

  use row <- list.map(list.range(0, stride - 1))
  p.Pos(#(col, row))
}
