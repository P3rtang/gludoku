import gleam/list
import gleam/option
import gleam/result
import gleam/set
import sudoku/cell/cell.{value}
import sudoku/pos.{type Pos, coords}
import sudoku/sudoku.{type Sudoku, Sudoku}
import sudoku/utils/get_box_values
import sudoku/utils/get_col_values
import sudoku/utils/get_row_values

pub fn values(sudoku: Sudoku, pos: Pos) -> Result(set.Set(Int), Nil) {
  let Sudoku(_, size) = sudoku
  let stride = size.0 * size.1
  let #(col, row) = pos |> coords(stride)

  use row_list <- result.try({
    use cells <- result.map(sudoku |> get_row_values.get(row))
    use cell <- list.map(cells)
    cell |> value
  })

  use col_list <- result.try({
    use cells <- result.map(sudoku |> get_col_values.get(col))
    use cell <- list.map(cells)
    cell |> value
  })

  use box_list <- result.map({
    use cells <- result.map(
      sudoku
      |> get_box_values.get({ col / 3 } + { row / 3 } * 3),
    )
    use cell <- list.map(cells)
    cell
    |> value
  })

  row_list
  |> list.append(col_list)
  |> list.append(box_list)
  |> list.filter(option.is_some)
  |> list.map(fn(v) { option.unwrap(v, 0) })
  |> set.from_list
}
