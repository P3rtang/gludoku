import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import lustre/attribute
import lustre/element
import lustre/element/html
import sudoku/cell/state.{type Mark, Mark}

pub fn view(mark: Mark) -> element.Element(state.Msg) {
  let corner_elements = {
    use num <- list.map(mark |> get_corner_values)
    html.div(
      [attribute.style("line-height", "1rem"), attribute.class("w-[6px]")],
      [html.text(num |> int.to_string)],
    )
  }

  let center_elements = {
    use num <- list.map(mark |> get_center_values)
    html.div(
      [attribute.style("line-height", "8px"), attribute.class("w-[6px]")],
      [html.text(num |> int.to_string)],
    )
  }

  html.div([attribute.class("w-full h-full flex relative")], [
    html.div(
      [
        attribute.class(
          "flex flex-row gap-[3px] self-start justify-self-start w-full p-1 flex-wrap h-[8px] absolute",
        ),
        attribute.style("font-size", "12px"),
      ],
      corner_elements,
    ),
    html.div(
      [
        attribute.class(
          "flex flex-row gap-[3px] self-center justify-self-center w-full p-1 flex-wrap font-semibold absolute justify-center items-center",
        ),
        attribute.style("font-size", "12px"),
      ],
      center_elements,
    ),
  ])
}

pub fn encode(mark: Mark) -> json.Json {
  let Mark(corner, center) = mark

  json.object([#("corner", json.int(corner)), #("center", json.int(center))])
}

pub fn decode() -> decode.Decoder(Mark) {
  use corner <- decode.field("corner", decode.int)
  use center <- decode.field("center", decode.int)

  decode.success(Mark(corner, center))
}

// fn then_some(b: Bool, v: val) -> option.Option(val) {
//   case b {
//     True -> option.Some(v)
//     False -> option.None
//   }
// }

pub fn then_ok(b: Bool, v: val, err: error) -> Result(val, error) {
  case b {
    True -> Ok(v)
    False -> Error(err)
  }
}

pub fn get_corner_values(mark: Mark) -> List(Int) {
  let Mark(corner, _) = mark

  [
    { corner |> int.bitwise_and(1) > 0 } |> then_ok(1, Nil),
    { corner |> int.bitwise_and(2) > 0 } |> then_ok(2, Nil),
    { corner |> int.bitwise_and(4) > 0 } |> then_ok(3, Nil),
    { corner |> int.bitwise_and(8) > 0 } |> then_ok(4, Nil),
    { corner |> int.bitwise_and(16) > 0 } |> then_ok(5, Nil),
    { corner |> int.bitwise_and(32) > 0 } |> then_ok(6, Nil),
    { corner |> int.bitwise_and(64) > 0 } |> then_ok(7, Nil),
    { corner |> int.bitwise_and(128) > 0 } |> then_ok(8, Nil),
    { corner |> int.bitwise_and(256) > 0 } |> then_ok(9, Nil),
  ]
  |> result.values
}

pub fn get_center_values(mark: Mark) -> List(Int) {
  let Mark(_, center) = mark

  [
    { center |> int.bitwise_and(1) > 0 } |> then_ok(1, Nil),
    { center |> int.bitwise_and(2) > 0 } |> then_ok(2, Nil),
    { center |> int.bitwise_and(4) > 0 } |> then_ok(3, Nil),
    { center |> int.bitwise_and(8) > 0 } |> then_ok(4, Nil),
    { center |> int.bitwise_and(16) > 0 } |> then_ok(5, Nil),
    { center |> int.bitwise_and(32) > 0 } |> then_ok(6, Nil),
    { center |> int.bitwise_and(64) > 0 } |> then_ok(7, Nil),
    { center |> int.bitwise_and(128) > 0 } |> then_ok(8, Nil),
    { center |> int.bitwise_and(256) > 0 } |> then_ok(9, Nil),
  ]
  |> result.values
}

pub fn toggle_corner_int(mark: Mark, int: Int) -> Mark {
  let Mark(corner, center) = mark
  Mark(
    1
      |> int.bitwise_shift_left(int - 1)
      |> int.bitwise_exclusive_or(corner),
    center,
  )
}

pub fn toggle_center_int(mark: Mark, int: Int) -> Mark {
  let Mark(corner, center) = mark
  Mark(
    corner,
    1
      |> int.bitwise_shift_left(int - 1)
      |> int.bitwise_exclusive_or(center),
  )
}
