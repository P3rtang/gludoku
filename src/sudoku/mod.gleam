import gleam/dynamic/decode
import gleam/list
import gleam/result
import gleam/set
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import sudoku/cell/cell
import sudoku/cell/mark
import sudoku/cell/state as cs
import sudoku/cursor/mod as cursor
import sudoku/history/history
import sudoku/input_mode/input_mode.{
  type KeyEvent, Insert, KeyEvent, Normal, Visual,
}
import sudoku/pos as p
import sudoku/selection
import sudoku/state.{type Model, type Msg, Model}
import sudoku/sudoku.{new}
import sudoku/utils/utils
import sudoku/validator/validator

pub type Sudoku =
  sudoku.Sudoku

const sudoku_stride = 9

const sudoku_list = [
  0, 0, 0, 8, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 1, 0, 0, 0, 8, 0, 0, 9, 0, 0, 0, 3,
  5, 0, 0, 0, 0, 0, 0, 0, 4, 6, 0, 5, 3, 0, 0, 0, 7, 0, 0, 9, 0, 0, 0, 6, 0, 5,
  0, 0, 0, 9, 0, 0, 3, 7, 2, 0, 0, 0, 4, 0, 0, 1, 0, 0, 0, 0, 0, 6, 7, 0, 0, 5,
  0, 0, 0,
]

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.simple(init, update, view)
  lustre.register(component, "my-sudoku")
}

fn init(_) -> Model {
  // mod.generate("first")
  sudoku_list
  |> utils.from_list(#(3, 3))
  |> result.unwrap(new())
  |> Model(
    p.Pos(#(4, 4)) |> cursor.Cursor(#(9, 9)),
    selection.new(),
    [],
    input_mode.new(),
  )
  |> setup_inputs
}

pub fn element() -> Element(void) {
  element.element("my-sudoku", [attribute.class("h-screen block")], [])
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    state.UserPressedKey(event) -> model |> handle_key_press(event)
  }
}

fn setup_inputs(model: Model) -> Model {
  let input = model.input

  let input = {
    use model <- input_mode.bind_char(input, [Normal, Visual], "j")
    let Model(cursor: cursor, ..) = model
    Model(..model, cursor: cursor.down(cursor))
  }

  let input = {
    use model <- input_mode.bind_char(input, [Normal, Visual], "k")
    let Model(cursor: cursor, ..) = model
    Model(..model, cursor: cursor.up(cursor))
  }

  let input = {
    use model <- input_mode.bind_char(input, [Normal, Visual], "h")
    let Model(cursor: cursor, ..) = model
    Model(..model, cursor: cursor.left(cursor))
  }

  let input = {
    use model <- input_mode.bind_char(input, [Normal, Visual], "l")
    let Model(cursor: cursor, ..) = model
    Model(..model, cursor: cursor.right(cursor))
  }

  let input = {
    use model <- input_mode.bind_char(input, [Normal], "u")
    let Model(sudoku: sudoku, history: hist, ..) = model
    let #(sudoku, hist) =
      hist
      |> history.undo(sudoku)
      |> result.unwrap(#(sudoku, hist))

    Model(..model, sudoku: sudoku, history: hist)
  }

  let input = {
    use model, _ <- input_mode.bind_mode_change(input)
    Model(..model, selection: selection.new())
  }

  let input = {
    use model, mode <- input_mode.bind_mode_change(input)
    case mode {
      input_mode.Visual -> {
        let Model(selection: sel, cursor: cursor.Cursor(c_pos, _), ..) = model
        Model(..model, selection: sel |> selection.toggle(c_pos))
      }
      _ -> model
    }
  }

  let input = {
    use model <- input_mode.bind_char(input, [Visual], "v")
    let Model(selection: sel, cursor: cursor.Cursor(c_pos, _), ..) = model
    Model(..model, selection: sel |> selection.toggle(c_pos))
  }

  let input = {
    use model, event <- input_mode.bind_mode(input, Insert)
    let Model(sudoku, cursor, sel, hist, ..) = model
    let cursor.Cursor(c_pos, _) = cursor

    let selected =
      sel
      |> set.insert(c_pos |> p.index(sudoku_stride))
      |> set.to_list
      |> list.map(p.Index)

    case event {
      KeyEvent(input_mode.Digit(num), False, False) -> {
        let hist = hist |> history.replace(sudoku, c_pos, cs.Filled(num))

        Model(
          ..model,
          history: hist,
          sudoku: sudoku |> set_cells(selected, cs.Filled(num)),
        )
      }
      KeyEvent(input_mode.Digit(num), _, ctrl) -> {
        let func = case ctrl {
          False -> mark.toggle_corner_int
          True -> mark.toggle_center_int
        }

        let #(sudoku, history) = case
          sudoku |> utils.get_index(c_pos |> p.index(9))
        {
          Ok(cs.Marking(cs.Mark(corner, center))) -> #(
            sudoku
              |> set_cells(
                selected,
                cs.Marking(cs.Mark(corner, center) |> func(num)),
              ),
            hist
              |> history.replace(
                sudoku,
                c_pos,
                cs.Marking(cs.Mark(corner, center)),
              ),
          )
          _ -> #(
            sudoku
              |> set_cells(selected, cs.Marking(cs.Mark(0, 0) |> func(num))),
            hist
              |> history.replace(sudoku, c_pos, cs.Marking(cs.Mark(0, 0))),
          )
        }

        Model(..model, sudoku:, history:)
      }
      _ -> {
        model
      }
    }
  }

  Model(..model, input:)
}

fn handle_key_press(model: Model, event: KeyEvent) -> Model {
  let #(input, func) = {
    model.input |> input_mode.handle_input(event)
  }

  let model = func(model)
  Model(..model, input:)
}

fn set_cells(sudoku: Sudoku, positions: List(p.Pos), value: cs.Cell) -> Sudoku {
  case positions {
    [pos, ..rest] ->
      sudoku |> utils.set_cell(pos, value) |> set_cells(rest, value)
    [] -> sudoku
  }
}

fn view(model: Model) -> Element(Msg) {
  let Model(sudoku:, cursor:, selection: sel, ..) = model
  let cursor.Cursor(c_pos, _) = cursor

  let on_keypress = {
    event.on("keydown", {
      use code <- decode.field("code", decode.string)
      use shift <- decode.field("shiftKey", decode.bool)
      use ctrl <- decode.field("ctrlKey", decode.bool)
      decode.success(
        state.UserPressedKey(input_mode.KeyEvent(
          code |> input_mode.parse,
          shift,
          ctrl,
        )),
      )
    })
  }

  let cell_view =
    {
      use row <- list.try_map(list.range(0, 8))
      use col <- list.try_map(list.range(0, 8))

      use cell <- result.map(
        sudoku |> utils.get_index(p.Pos(#(col, row)) |> p.index(9)),
      )
      cell.element(
        cs.Model(
          cell,
          p.Pos(#(col, row)) == c_pos,
          sel |> set.contains(p.Pos(#(col, row)) |> p.index(sudoku_stride)),
          model.input.mode,
        ),
        [attribute.value("focus")]
          |> list.append(p.Pos(#(col, row)) |> cell.border),
      )
    }
    |> result.map(fn(l) {
      use l <- list.map(l)
      html.div([attribute.class("flex flex-row h32")], l)
    })
    |> result.unwrap([html.div([], [])])

  html.div([], [
    html.div(
      [
        on_keypress,
        attribute.tabindex(1),
        attribute.autofocus(True),
        attribute.class("p-16 h-full w-full"),
        attribute.style("font-family", "monospace"),
      ],
      cell_view,
    ),
    html.text(
      case
        list.all(
          [
            sudoku |> validator.validate_boxes,
            sudoku |> validator.validate_cols,
            sudoku |> validator.validate_rows,
          ],
          result.is_ok,
        )
      {
        True -> "valid"
        False -> "invalid"
      },
    ),
  ])
}
