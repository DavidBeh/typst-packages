#import "@preview/t4t:0.4.3": *
#import "@preview/oxifmt:1.0.0": strfmt
#import "regex-util.typ": escape
#import "@preview/zebraw:0.6.1"
#let default_comment_syntaxes = yaml("./comments.yaml")

#let a = 2;

/// Returns the type of comment syntax: `block` for block comments, which is an array of two strings [start, end], or `line` for line comments, which is a single string.
///
/// *Example:*
///
/// ```typ
/// #assert.eq(get_comment_syntax_type(("/*", "*/")), block);
/// // std can be added to avoid collisions
/// #assert.eq(get_comment_syntax_type("//"), std.line);
/// ```
///
/// -> line | block | none
#let get_comment_syntax_type(
  /// The comment syntax to check. -> str | array of two str
  syntax,
  /// If `true`, the function will return `none` instead of panicking on invalid input. -> bool
  dont_panic_invalid: false,
) = {
  if is-arr(synatx) and is-length(2) and test.all-of-type(str, ..syntax) {
    return std.block
  }
  if is-str(syntax) {
    return std.line
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

