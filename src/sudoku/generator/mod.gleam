import gleam/bit_array
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import sudoku/cell/cell
import sudoku/cell/state.{Empty, Solved} as cs
import sudoku/pos.{type Pos} as p
import sudoku/sudoku.{type Sudoku, Sudoku}
import sudoku/utils/utils
import sudoku/validator/validator

const default_mod = 0x80000000

// 2 ** 31

pub fn pattern(seed: Int, offset: Int) -> set.Set(Int) {
  add_pattern(seed, offset, [] |> set.from_list)
}

pub fn add_pattern(
  seed: Int,
  offset: Int,
  pattern: set.Set(Int),
) -> set.Set(Int) {
  let rand = lcg_with_mod(seed, 81) + 1
  let new = pattern |> set.insert(rand)

  case new |> set.size() < 30 {
    True -> add_pattern(seed * offset, offset, new)
    False -> new
  }
}

pub fn retry_pattern(seed: Int, offset: Int) -> Result(Sudoku, Nil) {
  let sudoku = {
    let pattern = pattern(seed, offset)

    use zero_sudoku <- result.try(
      list.repeat(0, 81) |> utils.from_list(#(3, 3)),
    )
    use sudoku <- result.map(
      zero_sudoku |> solve_with_seed(seed, 0, p.Index(0)),
    )
    sudoku |> apply_pattern(pattern)
  }

  // let solve_count =
  //   {
  //     use s <- result.try(sudoku)
  //     solve_count(s, 0, seed, 0, p.Index(0))
  //   }
  //   |> result.map(fn(c) { c.1 })
  //   |> result.unwrap(0)
  //   |> echo

  sudoku
  // case sudoku {
  //   Ok(s) if solve_count == 1 -> Ok(s)
  //   _ -> retry_pattern(seed, offset + 1)
  // }
}

pub fn apply_pattern(sudoku: Sudoku, pattern: set.Set(Int)) -> Sudoku {
  let Sudoku(values, size) = sudoku
  let values = {
    use key, value <- dict.map_values(values)
    case pattern |> set.contains(key) {
      True -> cs.Preset(value |> cell.value |> option.unwrap(0))
      False -> cs.Empty
    }
  }
  Sudoku(values, size)
}

pub fn generate(seed: String) -> Result(Sudoku, Nil) {
  use val <- result.try(
    seed
    |> bit_array.from_string
    |> bit_array.base16_encode()
    |> int.base_parse(16),
  )

  retry_pattern(val, 111)
}

pub fn lcg_with_mod(seed: Int, modulus: Int) -> Int {
  { seed * 22_695_477 + 1 } % modulus
}

pub fn lcg(seed: Int) -> Int {
  lcg_with_mod(seed, default_mod)
}

pub fn solve(sudoku: Sudoku) -> Sudoku {
  case solve_with_seed(sudoku, 42, 0, p.Index(0)) {
    Ok(s) -> s
    _ -> sudoku
  }
}

pub fn solve_count(
  sudoku: Sudoku,
  solves: Int,
  seed: Int,
  offset: Int,
  pos: Pos,
) -> Result(#(Sudoku, Int), Nil) {
  let Sudoku(values, size) = sudoku
  let stride = size.0 * size.1

  let idx = pos |> p.index(stride)

  let is_valid =
    [
      sudoku |> validator.validate_rows,
      sudoku |> validator.validate_cols,
      sudoku |> validator.validate_boxes,
    ]
    |> result.all
    |> result.is_ok

  #("idx: ", idx, "offset: ", offset, "solves: ", solves) |> echo

  case stride * stride == idx, is_valid {
    True, True -> {
      Ok(#(sudoku, solves + 1))
    }
    _, False -> {
      Error(Nil)
    }
    False, True -> {
      use cell <- result.try(values |> dict.get(idx))

      case cell {
        Empty -> {
          let filled =
            sudoku
            |> utils.possibilities(pos)
            |> result.unwrap(set.from_list([]))

          let possible =
            set.from_list([1, 2, 3, 4, 5, 6, 7, 8, 9])
            |> set.difference(filled)
            |> set.to_list

          use _ <- result.try(case possible |> list.length <= offset {
            True -> Error(Nil)
            False -> Ok(Nil)
          })

          let rand =
            { lcg(seed + { pos |> p.index(stride) }) + offset }
            % list.length(possible)

          let assert Ok(#(_, value)) =
            list.reduce(list.zip(list.range(0, stride), possible), fn(acc, val) {
              case val.0 == rand {
                True -> val
                False -> acc
              }
            })

          use filled_in <- result.try(
            sudoku |> utils.set_index(idx, Solved(value)),
          )
          case filled_in |> solve_count(solves, seed, 0, p.Index(idx + 1)) {
            Error(_) if offset < stride ->
              sudoku |> solve_count(solves, seed, offset + 1, pos)
            Error(_) -> Error(Nil)
            Ok(#(_, solves)) if offset < stride ->
              sudoku |> solve_count(solves, seed, offset + 1, pos)
            Ok(#(s, solves)) -> Ok(#(s, solves))
          }
        }
        _ -> sudoku |> solve_count(solves, seed, 0, p.Index(idx + 1))
      }
    }
  }
}

pub fn solve_with_seed(
  sudoku: Sudoku,
  seed: Int,
  offset: Int,
  pos: Pos,
) -> Result(Sudoku, Nil) {
  let Sudoku(values, size) = sudoku
  let stride = size.0 * size.1

  let idx = pos |> p.index(stride)

  let is_valid =
    [
      sudoku |> validator.validate_rows,
      sudoku |> validator.validate_cols,
      sudoku |> validator.validate_boxes,
    ]
    |> result.all
    |> result.is_ok

  case stride * stride == idx, is_valid {
    True, True -> {
      Ok(sudoku)
    }
    _, False -> {
      Error(Nil)
    }
    False, True -> {
      use cell <- result.try(values |> dict.get(idx))

      case cell {
        Empty -> {
          let filled =
            sudoku
            |> utils.possibilities(pos)
            |> result.unwrap(set.from_list([]))

          let possible =
            set.from_list([1, 2, 3, 4, 5, 6, 7, 8, 9])
            |> set.difference(filled)
            |> set.to_list

          use _ <- result.try(case possible |> list.length <= offset {
            True -> Error(Nil)
            False -> Ok(Nil)
          })

          let rand =
            { lcg(seed + { pos |> p.index(stride) }) + offset }
            % list.length(possible)

          let assert Ok(#(_, value)) =
            list.reduce(list.zip(list.range(0, stride), possible), fn(acc, val) {
              case val.0 == rand {
                True -> val
                False -> acc
              }
            })

          use filled_in <- result.try(
            sudoku |> utils.set_index(idx, Solved(value)),
          )
          case filled_in |> solve_with_seed(seed, 0, p.Index(idx + 1)) {
            Error(_) if offset < stride ->
              sudoku |> solve_with_seed(seed, offset + 1, pos)
            Error(_) -> Error(Nil)
            Ok(s) -> Ok(s)
          }
        }
        _ -> sudoku |> solve_with_seed(seed, 0, p.Index(idx + 1))
      }
    }
  }
}

pub fn is_valid(sudoku: Sudoku) -> Bool {
  {
    use #(idx, val) <- list.map(sudoku |> utils.to_dict |> dict.to_list)
    let box =
      verify_idx_list(sudoku, utils.box_positions(p.Index(idx), #(3, 3)), val)
    let row = verify_idx_list(sudoku, utils.row_positions(p.Index(idx), 9), val)
    let col = verify_idx_list(sudoku, utils.col_positions(p.Index(idx), 9), val)
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
