import { Ok, Error } from "./gleam.mjs";

const read_file = (path) => {
    fetch(path)
        .then(result => Ok(result.text()))
        .catch(() => Error(undefined))
}
