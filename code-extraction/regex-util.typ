

/// Escapes all regular expression meta characters in `str`.
///
/// The string returned may be safely used as a literal in a regular expression.
///
/// - str (str): The input.
/// -> str
#let escape(str) = {

  // Source: https://docs.rs/regex-syntax/latest/regex_syntax/fn.escape.html

  let meta_chars = (
    "\\",
    ".",
    "+",
    "*",
    "?",
    "(",
    ")",
    ",",
    "[",
    "]",
    "{",
    "}",
    "^",
    "$",
    "#",
    "&",
    "-",
    "~",
  )

  let replace_regex = "[" + meta_chars.map(it => "\\" + it).sum() + "]"


  return str.replace(regex(replace_regex), dict => "\\" + dict.text)
}