import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import sudoku/cell/state.{type Mark, Center, Corner}

pub fn view(mark: Mark) -> element.Element(state.Msg) {
  let values = mark |> get_values

  let elements = {
    use num <- list.map(values)
    html.div(
      [attribute.style("line-height", "1rem"), attribute.class("w-[6px]")],
      [html.text(num |> int.to_string)],
    )
  }

  html.div(
    [
      attribute.class(
        "flex flex-row gap-[3px] self-start justify-self-start w-full p-1 flex-wrap h-[8px]",
      ),
      attribute.style("font-size", "12px"),
    ],
    elements,
  )
}

pub fn encode(mark: Mark) -> json.Json {
  let #(kind, value) = case mark {
    Corner(val) -> #("Corner", val)
    Center(val) -> #("Center", val)
  }

  json.object([#("kind", kind |> json.string), #("value", value |> json.int)])
}

pub fn decode() -> decode.Decoder(Mark) {
  use kind <- decode.field("kind", decode.string)
  use value <- decode.field("value", decode.int)

  case kind {
    "Corner" -> decode.success(Corner(value))
    "Center" -> decode.success(Center(value))
    _ -> decode.failure(Corner(0), "Kind")
  }
}

// fn then_some(b: Bool, v: val) -> option.Option(val) {
//   case b {
//     True -> option.Some(v)
//     False -> option.None
//   }
// }

fn then_ok(b: Bool, v: val, err: error) -> Result(val, error) {
  case b {
    True -> Ok(v)
    False -> Error(err)
  }
}

fn get_values(mark: Mark) -> List(Int) {
  let value = case mark {
    Corner(val) -> val
    Center(val) -> val
  }

  [
    { value |> int.bitwise_and(1) > 0 } |> then_ok(1, Nil),
    { value |> int.bitwise_and(2) > 0 } |> then_ok(2, Nil),
    { value |> int.bitwise_and(4) > 0 } |> then_ok(3, Nil),
    { value |> int.bitwise_and(8) > 0 } |> then_ok(4, Nil),
    { value |> int.bitwise_and(16) > 0 } |> then_ok(5, Nil),
    { value |> int.bitwise_and(32) > 0 } |> then_ok(6, Nil),
    { value |> int.bitwise_and(64) > 0 } |> then_ok(7, Nil),
    { value |> int.bitwise_and(128) > 0 } |> then_ok(8, Nil),
    { value |> int.bitwise_and(256) > 0 } |> then_ok(9, Nil),
  ]
  |> list.filter_map(fn(a) { a })
}

pub fn toggle_int(mark: Mark, int: Int) -> Mark {
  case mark {
    Corner(val) ->
      1
      |> int.bitwise_shift_left(int - 1)
      |> int.bitwise_exclusive_or(val)
      |> Corner
    Center(val) ->
      1
      |> int.bitwise_shift_left(int - 1)
      |> int.bitwise_exclusive_or(val)
      |> Center
  }
}
