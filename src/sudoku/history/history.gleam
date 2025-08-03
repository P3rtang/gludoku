import gleam/list
import gleam/result
import sudoku/cell/mod.{type Cell}
import sudoku/pos as p
import sudoku/pos.{type Pos}
import sudoku/sudoku.{type Sudoku, Sudoku}
import sudoku/utils/utils

pub type History =
  List(HistoryItem)

pub type HistoryItem {
  Insert(Cell, Pos)
  Remove(Cell, Pos)
  Replace(old: Cell, new: Cell, pos: Pos)
}

pub fn insert(hist: History, cell: Cell, pos: Pos) -> History {
  hist |> list.append([Insert(cell, pos)])
}

pub fn remove(hist: History, cell: Cell, pos: Pos) -> History {
  hist |> list.append([Remove(cell, pos)])
}

pub fn replace(hist: History, sudoku: Sudoku, pos: Pos, new: Cell) -> History {
  let Sudoku(_, size) = sudoku

  case sudoku |> utils.get_index(pos |> p.index(size.0 * size.1)) {
    Ok(old) -> hist |> list.append([Replace(old, new, pos)])
    Error(_) -> hist |> list.append([Insert(new, pos)])
  }
}

pub fn undo(hist: History, sudoku: Sudoku) -> Result(#(Sudoku, History), Nil) {
  use #(hist, cell, pos) <- result.map(hist |> pop)
  #(sudoku |> utils.force_cell(pos, cell), hist)
}

pub fn pop(hist: History) -> Result(#(History, Cell, Pos), Nil) {
  use item <- result.map(hist |> list.last())
  let hist = hist |> list.take(list.length(hist) - 1)

  case item {
    Insert(cell, pos) -> #(hist, cell, pos)
    Remove(cell, pos) -> #(hist, cell, pos)
    Replace(old, _new, pos) -> #(hist, old, pos)
  }
}
