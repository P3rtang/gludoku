import gleam/list
import gleam/option
import gleam/result
import sudoku/cell/cell
import sudoku/state.{type Sudoku, Sudoku}
import sudoku/utils/get_row_values
import sudoku/validator/error.{type Reason, InvalidBoxes}
import sudoku/validator/validate_n

pub fn validate(sudoku: Sudoku) -> Result(Nil, Reason) {
  let Sudoku(_, size) = sudoku

  {
    use box_idx <- list.try_map(list.range(0, size.0 * size.1 - 1))
    use cells <- result.try(
      sudoku
      |> get_row_values.get(box_idx)
      |> result.replace_error(InvalidBoxes),
    )

    cells
    |> list.map(cell.value)
    |> list.map(fn(o) { o |> option.unwrap(0) })
    |> validate_n.validate_n(9)
  }
  |> result.replace(Nil)
}
