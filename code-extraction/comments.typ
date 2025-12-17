#import "@preview/t4t:0.4.3": *
#import "@preview/oxifmt:1.0.0": strfmt
#import "regex-util.typ": escape
#import "@preview/zebraw:0.6.1"
#let default_comment_syntaxes = yaml("./comments.yaml")

#let a = 2;

/// Returns the type of comment syntax.
///
/// ->  "line" | "block" | none
#let get_comment_syntax_type(
  /// The comment syntax to check. The following formats are supported:
  ///
  /// / `str`: for line comments, e.~g. ```typc "//"```
  /// / `array of two str`: for block comments, e.~g. ```typc ("/*", "*/")```
  ///
  /// -> str | array
  syntax,
  /// If `true`, the function will return `none` instead of panicking on invalid input. -> bool
  dont_panic_invalid: false,
) = {
  if is-arr(synatx) and is-length(2) and test.all-of-type(str, ..syntax) {
    return "block"
  }
  if is-str(syntax) {
    return "line"
  }
  if dont_panic_invalid {
    return none
  }

  panic("comment syntaxes must be str or array of two str but was" + repr(syntax))
}

/// Returns a regex pattern *string* that matches comments of the given syntax.
///
/// -> str
#let get_comment_pattern(
/// The comment syntax. See @get_comment_syntax_type for the expected formats.
/// -> str | array of two str
  syntax,
) = {
  let comment_type = get_comment_syntax_type(syntax)

  if comment_type == std.line {
    let line = escape(syntax)

    // match whole line:
    // whitespaces* line whitespaces* (anything* non-greedy)
    let pattern = strfmt("^ *{0} *(.*?) *$", line)
    return pattern
  } else if comment_type == std.block {
    let (start, end) = syntax.map(escape)

    // match whole line:
    // whitespaces* start whitespaces* (anything* non-greedy) whitespaces* end whitespaces*
    let pattern = strfmt("^ *{0} *(.*?) *{1} *$", start, end)
    return pattern
  }

  panic("unexpected bug. invalid comment syntax: " + repr(syntax))
}

