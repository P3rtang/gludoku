import lustre
import lustre/element.{type Element}

import sudoku/mod as sudoku

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model =
  Int

fn init(_) -> Model {
  0
}

type Msg {
  UserClickedIncrement
  UserClickedDecrement
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserClickedIncrement -> model + 1
    UserClickedDecrement -> model - 1
  }
}

// VIEW ------------------------------------------------------------------------

/// The `view` function is called after every `update`. It takes the current
/// state of our application and renders it as an `Element`
///
fn view(_model: Model) -> Element(Msg) {
  let s = sudoku.new()
  s |> sudoku.view
}
