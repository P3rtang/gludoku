import gleam/dynamic/decode
import gleam/int
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
import sudoku/generator/mod
import sudoku/history/history
import sudoku/pos as p
import sudoku/selection
import sudoku/state.{type KeyEvent, type Model, type Msg, Model}
import sudoku/sudoku.{new}
import sudoku/utils/utils
import sudoku/validator/validator

pub type Sudoku =
  sudoku.Sudoku

const sudoku_stride = 9

const sudoku_list = [
  0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 4, 7, 0, 0, 9, 4, 0, 0, 0, 7, 0, 0,
  6, 0, 0, 0, 0, 0, 0, 0, 7, 0, 8, 0, 0, 0, 0, 0, 0, 0, 5, 0, 6, 0, 1, 0, 3, 4,
  0, 0, 0, 0, 3, 0, 6, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 7, 0, 0,
  5, 8, 2,
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
  |> Model(p.Pos(#(4, 4)) |> cursor.Cursor(#(9, 9)), selection.new(), [])
}

pub fn element() -> Element(void) {
  element.element("my-sudoku", [attribute.class("h-screen block")], [])
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    state.UserPressedKey(event) -> model |> handle_key_press(event)
  }
}

fn handle_key_press(model: Model, event: KeyEvent) -> Model {
  let Model(sudoku, cursor, sel, hist) = model
  let cursor.Cursor(c_pos, _) = cursor

  let selected =
    sel
    |> set.insert(c_pos |> p.index(sudoku_stride))
    |> set.to_list
    |> list.map(p.Index)

  let state.KeyEvent(key, _code, shift, ctrl) = event

  let num = key |> int.parse

  case key, num {
    "j", _ -> {
      Model(sudoku, cursor |> cursor.down, sel, hist)
    }
    "k", _ -> {
      Model(sudoku, cursor |> cursor.up, sel, hist)
    }
    "h", _ -> {
      Model(sudoku, cursor |> cursor.left, sel, hist)
    }
    "l", _ -> {
      Model(sudoku, cursor |> cursor.right, sel, hist)
    }
    " ", _ -> {
      Model(sudoku, cursor, sel |> selection.toggle(c_pos), hist)
    }
    _, Ok(val) -> {
      case shift, ctrl {
        False, False -> {
          let hist = hist |> history.replace(sudoku, c_pos, cs.Filled(val))

          Model(
            sudoku |> set_cells(selected, cs.Filled(val)),
            cursor,
            sel,
            hist,
          )
        }
        True, _ -> {
          case sudoku |> utils.get_index(c_pos |> p.index(9)) {
            Ok(cs.Marking(cs.Corner(c))) ->
              Model(
                sudoku
                  |> set_cells(
                    selected,
                    cs.Marking(cs.Corner(c) |> mark.toggle_int(val)),
                  ),
                cursor,
                sel,
                hist,
              )
            _ ->
              Model(
                sudoku
                  |> set_cells(
                    selected,
                    cs.Marking(cs.Corner(0) |> mark.toggle_int(val)),
                  ),
                cursor,
                sel,
                hist,
              )
          }
        }
        False, True -> {
          case sudoku |> utils.get_index(c_pos |> p.index(9)) {
            Ok(cs.Marking(cs.Center(c))) -> {
              let hist =
                hist |> history.replace(sudoku, c_pos, cs.Marking(cs.Center(c)))

              Model(
                sudoku
                  |> set_cells(
                    selected,
                    cs.Marking(cs.Center(c) |> mark.toggle_int(val)),
                  ),
                cursor,
                sel,
                hist,
              )
            }
            _ -> {
              let hist =
                hist |> history.replace(sudoku, c_pos, cs.Marking(cs.Center(0)))

              Model(
                sudoku
                  |> set_cells(
                    selected,
                    cs.Marking(cs.Center(0) |> mark.toggle_int(val)),
                  ),
                cursor,
                sel,
                hist,
              )
            }
          }
        }
      }
    }
    "z", _ -> {
      case ctrl {
        True -> {
          let #(sudoku, hist) =
            hist
            |> history.undo(sudoku)
            |> result.unwrap(#(sudoku, hist))

          Model(sudoku, cursor, sel, hist)
        }
        False -> model
      }
    }
    "Escape", _ -> Model(sudoku, cursor, selection.new(), hist)
    key, _ -> {
      echo key
      model
    }
    // _, _ -> model
  }
}

fn set_cells(sudoku: Sudoku, positions: List(p.Pos), value: cs.Cell) -> Sudoku {
  case positions {
    [pos, ..rest] ->
      sudoku |> utils.set_cell(pos, value) |> set_cells(rest, value)
    [] -> sudoku
  }
}

fn view(model: Model) -> Element(Msg) {
  let Model(sudoku, cursor, sel, _) = model
  let cursor.Cursor(c_pos, _) = cursor

  let on_keypress = {
    event.on("keydown", {
      use key <- decode.field("key", decode.string)
      use code <- decode.field("code", decode.string)
      use shift <- decode.field("shiftKey", decode.bool)
      use ctrl <- decode.field("ctrlKey", decode.bool)
      decode.success(
        state.UserPressedKey(state.KeyEvent(key, code, shift, ctrl)),
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
