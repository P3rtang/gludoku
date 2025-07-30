import gleam/int
import gleam/list
import gleam/result
import sudoku/validator/error.{type Reason, DoubleValue, IncorrectLength}

pub fn validate_n(values: List(Int), length: Int) -> Result(Nil, Reason) {
  use _ <- result.try(case values |> list.length == length {
    True -> Ok(Nil)
    False -> Error(IncorrectLength)
  })

  values
  |> list.zip(list.range(0, length))
  |> list.fold(Ok(0), fn(acc, item) {
    use acc <- result.try(acc)
    let #(val, idx) = item

    case val == 0 {
      True -> Ok(acc)
      False -> {
        case acc |> int.bitwise_and(1 |> int.bitwise_shift_left(val - 1)) == 0 {
          True ->
            Ok(acc |> int.bitwise_or(1 |> int.bitwise_shift_left(val - 1)))
          False -> Error(DoubleValue(idx))
        }
      }
    }
  })
  |> result.replace(Nil)
}
