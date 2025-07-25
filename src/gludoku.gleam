import lustre
import lustre/element.{type Element}
import sudoku/cell/cell
import sudoku/mod as sudoku

pub fn main() {
  let app = lustre.simple(init, update, view)

  let assert Ok(_) = sudoku.register()
  let assert Ok(_) = cell.register()
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model =
  Nil

fn init(_) -> Model {
  Nil
}

type Msg

fn update(model: Model, _: Msg) -> Model {
  model
}

// VIEW ------------------------------------------------------------------------

/// The `view` function is called after every `update`. It takes the current
/// state of our application and renders it as an `Element`
///
fn view(_: Model) -> Element(Msg) {
  sudoku.element()
}
