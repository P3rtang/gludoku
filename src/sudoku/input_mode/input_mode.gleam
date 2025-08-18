import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Mode {
  Normal
  Insert
  Visual
}

pub fn encode(mode: Mode) -> String {
  case mode {
    Normal -> "normal"
    Insert -> "insert"
    Visual -> "visual"
  }
}

pub fn decode() -> decode.Decoder(Mode) {
  use str <- decode.then(decode.string)
  case str {
    "normal" -> decode.success(Normal)
    "insert" -> decode.success(Insert)
    "visual" -> decode.success(Visual)
    _ -> decode.failure(Normal, "Unsupported mode: " <> str)
  }
}

pub type InputMode(s) {
  InputMode(
    mode: Mode,
    normal: dict.Dict(KeyEvent, fn(s) -> s),
    insert: #(dict.Dict(KeyEvent, fn(s) -> s), fn(s, KeyEvent) -> s),
    visual: dict.Dict(KeyEvent, fn(s) -> s),
    on_mode_change: List(fn(s, Mode) -> s),
  )
}

pub fn new() -> InputMode(s) {
  InputMode(
    Normal,
    dict.new(),
    #(dict.new(), fn(s: s, _) { s }),
    dict.new(),
    [],
  )
}

pub type KeyEvent {
  KeyEvent(code: KeyCode, shift: Bool, ctrl: Bool)
}

pub type KeyCode {
  Digit(Int)
  Char(String)
}

pub fn parse(key_code: String) -> KeyCode {
  case key_code {
    "Key" <> char -> Char(char |> string.lowercase)
    "Digit" <> num -> Digit(num |> int.parse |> result.unwrap(0))
    key -> {
      key |> echo
      Char(key_code)
    }
  }
}

pub fn noop(s: s) -> s {
  s
}

pub fn handle_input(
  mode: InputMode(s),
  event: KeyEvent,
) -> #(InputMode(s), fn(s) -> s) {
  case mode, event {
    // TODO: bind these like normal keybindings so they can be overwritten
    InputMode(Normal, ..), KeyEvent(Char("i"), False, False) -> {
      #(InputMode(..mode, mode: Insert), noop)
    }

    InputMode(Visual, ..), KeyEvent(Char("i"), False, False) -> {
      #(InputMode(..mode, mode: Insert), noop)
    }

    InputMode(Normal, ..), KeyEvent(Char("v"), False, False) -> {
      #(InputMode(..mode, mode: Visual), fn(s: s) {
        use acc, func <- list.fold(mode.on_mode_change, s)
        func(acc, Visual)
      })
    }

    InputMode(..), KeyEvent(Char("Escape"), _, _) -> {
      #(InputMode(..mode, mode: Normal), fn(s: s) {
        use acc, func <- list.fold(mode.on_mode_change, s)
        func(acc, Normal)
      })
    }

    InputMode(m, n, i, v, _), event -> {
      let mapping = case m {
        Normal -> n
        Insert -> i.0
        Visual -> v
      }

      case mapping |> dict.get(event) {
        Ok(func) -> #(mode, func)
        Error(_) if mode.mode == Insert -> #(mode, fn(s: s) { i.1(s, event) })
        Error(_) -> #(mode, noop)
      }
    }
  }
}

pub fn bind(
  input: InputMode(s),
  modes: List(Mode),
  key: KeyEvent,
  callback: fn(s) -> s,
) -> InputMode(s) {
  use input, mode <- list.fold(modes, input)
  let InputMode(_, n, i, v, _) = input
  case mode {
    Normal -> {
      InputMode(..input, normal: n |> dict.insert(key, callback))
    }
    Insert -> {
      InputMode(..input, insert: #(i.0 |> dict.insert(key, callback), i.1))
    }
    Visual -> {
      InputMode(..input, visual: v |> dict.insert(key, callback))
    }
  }
}

pub fn bind_char(
  input: InputMode(s),
  modes: List(Mode),
  char: String,
  callback: fn(s) -> s,
) -> InputMode(s) {
  input |> bind(modes, KeyEvent(Char(char), False, False), callback)
}

pub fn bind_mode(
  input: InputMode(s),
  mode: Mode,
  callback: fn(s, KeyEvent) -> s,
) -> InputMode(s) {
  case input, mode {
    _, Normal -> {
      input
    }

    InputMode(insert: i, ..), Insert -> {
      InputMode(..input, insert: #(i.0, callback))
    }

    _, Visual -> {
      input
    }
  }
}

pub fn bind_mode_change(
  input: InputMode(s),
  callback: fn(s, Mode) -> s,
) -> InputMode(s) {
  InputMode(
    ..input,
    on_mode_change: input.on_mode_change |> list.append([callback]),
  )
}
