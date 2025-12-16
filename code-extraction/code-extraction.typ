#import "documentation.typ": print_docs

#let open(data: str) = {
  [Test]
}

#let a = (
  close: (a: str) => {},
)


/// A _region opener_ that returns `none` if no pattern matches.
///
/// -> function(str)
#let pattern_region_opener(
  /// A array of regex patterns. Each pattern must have a capture group. -> array of str
  patterns,
  /// A function with the same signature as @extract_lines.region_starter.
  /// This function is called when a pattern matches. It takes the captured text of the first capture group as input.
  ///
  /// -> function
  next
) = {
  let regexes = patterns.map(regex)

  let match(text) = {
    for pattern in regexes {
      let match = text.match(pattern)
      if match != none {
        let capture = match.captures.at(0)
        return capture
      }
    }
    return none
  }

  return text => {
    let capture = match(text)
    if capture != none {
      return next(capture)
    } else {
      return none
    }
  }
}





/// Extracts lines
///
/// -> dictionary
#let extract_lines(
  /// Input text to process. -> str
  text,
  /// A *region starter* is a function that processes a single line and returns an _array of region closers_ or `none`.
  ///
  /// It takes a single `str` as a positional parameter for each line to process and returns one of the following:
  ///
  /// / `none`: Indicates that the line is a _regular line_ and not a region marker line, except if a _region closer_ closes a region at this line.
  /// / `array`: Indicates that the line is a _region marker line_. This array contains zero or more _region closers_
  ///
  /// A *region closer* is a function with the same parameter signature and the following return values. It is called for each subsequent line until it closes the region.
  /// If the end of the input text is reached and the region is still not closed, the _region closer_ is called with `none` as input.
  ///
  /// / `none`: Indicates that the line is a _regular line_, except if the _region_opener_ or another _region closer_ does not return `none` for this line.
  ///  If `none` is returned when the input was `none`, the region is discarded.
  ///
  /// / `any`: Any non-`none` value closes the region at this line, which makes it a _region marker line_. The region is associated with the returned data.
  ///  If this is returned when the input was `none`, the region is stored as a half-opened region.
  ///
  /// -> function
  region_starter,
) = {}

#extract_lines(read("test.cs"), pattern_region_opener((), text => {

}))


#print_docs("", read("./code-extraction.typ"))
