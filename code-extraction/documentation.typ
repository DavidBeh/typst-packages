#import "@preview/tidy:0.4.3"
#import "@preview/t4t:0.4.3": get
#import "comments.typ"


#let create_quick_inline_raw_show_rule(
  prefixes: (
    t: "typ",
    c: "typc",
    m: "typm",
  ),
) = it => {
  show raw.where(block: false, lang: none): it => {
    for (prefix, lang) in prefixes {
      let start_pattern = prefix + " "

      if it.text.starts-with(start_pattern) {
        let replacement = it.text.slice(start_pattern.len())


        let args = it.fields()

        _ = args.remove("text")
        _ = args.remove("lines")
        _ = args.remove("lang")

        return {
          show raw: set std.text(1em / 0.8)
          raw(replacement, lang: lang, ..args)
        }
      }
    }
    it
  }
  it
}

/// Documents the given content using tidy and zebraw.
///
/// -> content
#let print_docs(
  /// The name of the module. -> str
  name,
  /// The .typ file to document. use `read("file.typ")` -> str
  content,
) = {
  import "@preview/zebraw:0.6.1": zebraw
  show: zebraw
  show: create_quick_inline_raw_show_rule()

  let docs = tidy.parse-module(
    content,
    name: name
  )
  tidy.show-module(
    docs,
    first-heading-level: 1,
  )
}




#show: create_quick_inline_raw_show_rule()

`c none`
