#import "@preview/tidy:0.4.3"
#import "@preview/t4t:0.4.3"
#import "comments.typ"

/// Documents the given content using tidy and zebraw.
///
/// -> content
#let print_docs(
  /// The name of the module. -> str
  name,
  /// The .typ file to document. use `read("file.typ")` -> str
  content
) = {

  import "@preview/zebraw:0.6.1": zebraw
  show: zebraw

  let docs = tidy.parse-module(
    content,
    name: name,
  )
  tidy.show-module(
    docs,
    first-heading-level: 1
  )
}