import gleam/list
import gleam/option
import gleam/result
import gleeunit
import gleeunit/should
import sudoku/cell/cell
import sudoku/utils/get_box_values
import sudoku/utils/get_col_values
import sudoku/utils/get_row_values
import sudoku/utils/utils as u
import sudoku/validator/validator.{validate_boxes, validate_cols, validate_rows}

// import sudoku/validator/mod as v
import sudoku/validator/validate_n

pub fn main() {
  gleeunit.main()
}

const sudoku_list = [
  5, 3, 4, 6, 7, 8, 9, 1, 2, 6, 7, 2, 1, 9, 5, 3, 4, 8, 1, 9, 8, 3, 4, 2, 5, 6,
  7, 8, 5, 9, 7, 6, 1, 4, 2, 3, 4, 2, 6, 8, 5, 3, 7, 9, 1, 7, 1, 3, 9, 2, 4, 8,
  5, 6, 9, 6, 1, 5, 3, 7, 2, 8, 4, 2, 8, 7, 4, 1, 9, 6, 3, 5, 3, 4, 5, 2, 8, 6,
  1, 7, 9,
]

const sudoku_list_err = [
  5, 3, 4, 6, 7, 8, 7, 1, 2, 6, 7, 2, 1, 9, 5, 3, 4, 8, 1, 9, 8, 3, 4, 2, 5, 6,
  7, 8, 5, 9, 7, 6, 1, 4, 2, 3, 4, 2, 6, 8, 5, 3, 7, 9, 1, 7, 1, 3, 9, 2, 4, 8,
  5, 6, 9, 6, 1, 5, 3, 2, 2, 1, 4, 2, 8, 7, 4, 1, 9, 6, 3, 5, 3, 4, 5, 2, 8, 6,
  1, 7, 9,
]

const size = #(3, 3)

pub fn validate_row_test() -> Result(Nil, Nil) {
  {
    use sudoku <- result.try(sudoku_list |> u.from_list(size))

    use idx <- list.try_map(list.range(0, 8))
    use cells <- result.try(sudoku |> get_row_values.get(idx))

    cells
    |> list.map(cell.value)
    |> list.map(fn(o) { o |> option.unwrap(0) })
    |> validate_n.validate_n(9)
    |> result.replace_error(Nil)
  }
  |> should.be_ok

  Ok(Nil)
}

pub fn validate_col_test() -> Result(Nil, Nil) {
  {
    use sudoku <- result.try(sudoku_list |> u.from_list(size))

    use box_idx <- list.try_map(list.range(0, 8))
    use cells <- result.try(sudoku |> get_col_values.get(box_idx))

    cells
    |> list.map(cell.value)
    |> list.map(fn(o) { o |> option.unwrap(0) })
    |> validate_n.validate_n(9)
    |> result.replace_error(Nil)
  }
  |> should.be_ok

  Ok(Nil)
}

pub fn validate_box_test() -> Result(Nil, Nil) {
  {
    use sudoku <- result.try(sudoku_list |> u.from_list(size))

    use box_idx <- list.try_map(list.range(0, 8))
    use cells <- result.try(sudoku |> get_box_values.get(box_idx))

    cells
    |> list.map(cell.value)
    |> list.map(fn(o) { o |> option.unwrap(0) })
    |> validate_n.validate_n(9)
    |> result.replace_error(Nil)
  }
  |> should.be_ok

  Ok(Nil)
}

pub fn validate_all_test() -> Result(Nil, Nil) {
  let _ = {
    use sudoku <- result.map(sudoku_list |> u.from_list(size))

    sudoku |> validate_rows |> should.be_ok
    sudoku |> validate_cols |> should.be_ok
    sudoku |> validate_boxes |> should.be_ok
  }

  let _ = {
    use sudoku <- result.map(sudoku_list_err |> u.from_list(size))
    sudoku |> validate_rows |> should.be_error
    sudoku |> validate_cols |> should.be_error
    sudoku |> validate_boxes |> should.be_error
  }

  Ok(Nil)
}
