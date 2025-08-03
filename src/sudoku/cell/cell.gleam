import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{Some}
import gleam/result
import lustre
import lustre/attribute
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import sudoku/cell/mark
import sudoku/cell/state.{
  type Model, type Msg, ClickCell, Empty, Filled, Marking, Preset, Solved,
  UpdateValue,
}
import sudoku/pos

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      {
        use value <- component.on_attribute_change("value")
        value
        |> json.parse(decode())
        |> result.map(UpdateValue)
        |> result.replace_error(Nil)
      },
    ])
  lustre.register(component, "sudoku-cell")
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(state.Model(Empty, False, False), effect.none())
}

pub fn element(
  model: Model,
  attrs: List(attribute.Attribute(msg)),
) -> Element(msg) {
  element.element(
    "sudoku-cell",
    attrs |> list.append([attribute.value(model |> encode |> json.to_string)]),
    [],
  )
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  #(
    case msg {
      UpdateValue(value) -> value
      ClickCell -> model
    },
    effect.none(),
  )
}

fn view(model: Model) -> Element(Msg) {
  let state.Model(cell, focus, selected) = model

  let #(elements, bg) = case cell {
    Empty -> #([], attribute.none())

    Preset(val) -> #(
      [html.text(val |> int.to_string)],
      attribute.style("background", "oklch(92.3% 0.003 48.717)"),
    )

    Filled(val) -> #([html.text(val |> int.to_string)], attribute.none())

    Solved(val) -> #([html.text(val |> int.to_string)], attribute.none())

    Marking(m) -> #([m |> mark.view], attribute.none())
  }

  html.div(
    [
      attribute.class("h-16 w-16 flex items-center justify-center text-4xl"),
      bg,
      case selected {
        True -> attribute.style("background", "oklch(91.7% 0.08 205.041)")
        False -> attribute.none()
      },
      case focus {
        True -> attribute.style("background", "oklch(90.1% 0.076 70.697)")
        False -> attribute.none()
      },
      event.on_click(ClickCell),
    ],
    elements,
  )
}

fn encode(model: Model) -> json.Json {
  let state.Model(cell, focus, selected) = model

  let #(kind, value) = case cell {
    Empty -> #("Empty", json.null())
    Preset(val) -> #("Preset", val |> json.int)
    Filled(val) -> #("Filled", val |> json.int)
    Solved(val) -> #("Solved", val |> json.int)
    Marking(m) -> #("Mark", m |> mark.encode)
  }

  json.object([
    #("kind", kind |> json.string),
    #("value", value),
    #("focus", focus |> json.bool),
    #("selected", selected |> json.bool),
  ])
}

fn decode() -> decode.Decoder(state.Model) {
  use kind <- decode.field("kind", decode.string)
  use value <- decode.field("value", decode.optional(decode.dynamic))
  use focus <- decode.field("focus", decode.bool)
  use selected <- decode.field("selected", decode.bool)

  case kind, value {
    "Empty", _ -> Ok(state.Model(Empty, focus, selected))
    "Preset", Some(val) -> {
      use val <- result.map(val |> decode.run(decode.int))
      state.Model(Preset(val), focus, selected)
    }
    "Filled", Some(val) -> {
      use val <- result.map(val |> decode.run(decode.int))
      state.Model(Filled(val), focus, selected)
    }
    "Mark", Some(val) -> {
      use m <- result.map(val |> decode.run(mark.decode()))
      state.Model(Marking(m), focus, selected)
    }
    "Solved", Some(val) -> {
      use m <- result.map(val |> decode.run(decode.int))
      state.Model(Solved(m), focus, selected)
    }
    _, _ -> Error(decode.decode_error("Kind", dynamic.nil()))
  }
  |> result.map(fn(cell) { decode.success(cell) })
  |> result.unwrap(decode.failure(state.Model(Empty, False, False), "Cell"))
}

pub fn border(p: pos.Pos) -> List(attribute.Attribute(void)) {
  let #(col, row) = case p {
    pos.Index(idx) -> #(idx % 9, idx / 9)
    pos.Pos(val) -> val
  }

  [
    attribute.classes([
      #("border-l border-t border-black", True),
      #("border-l-2", col % 3 == 0),
      #("border-t-2", row % 3 == 0),
      #("border-r-2", col == 8),
      #("border-b-2", row == 8),
    ]),
  ]
}

pub fn value(cell: state.Cell) -> option.Option(Int) {
  case cell {
    Empty -> option.None
    Preset(val) -> option.Some(val)
    Filled(val) -> option.Some(val)
    Solved(val) -> option.Some(val)
    Marking(_) -> option.None
  }
}
