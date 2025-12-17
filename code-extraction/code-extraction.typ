#import "documentation.typ": print_docs

/// A _line classifier / region closer_ that returns `none` if no pattern matches, or calls `next` with the first regex capture group text.
///
/// -> function(str)
#let pattern_filter_stage(
  /// A array of regex patterns. Each pattern must have a capture group. -> array of str
  patterns,
  /// A function with the same signature as @scan_regions_ll.line_classifier.
  /// This function is called when a pattern matches. It takes the captured text of the first capture group as input.
  /// Pattern matching is skipped if `patterns` is `none`, in which case `next` is called with `none` as input.
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
    if text == none {
      return next(none)
    }

    let capture = match(text)
    if capture != none {
      return next(capture)
    } else {
      return none
    }
  }
}

/// Low level function to scan regions in text.
///
/// Returns a dictionary with the following keys:
///
/// - `marker_line_numbers`: An array of integers representing the line numbers (1-based) of all region marker lines. Sorted in ascending order.
/// - `regions`: An dictionary where each key is the data associated with a region (_region data_). As multiple regions can have the same data, the value
///              for each key is an array where each item describes a region with that data.
///              Each item is an tuple (`array`) representing the start and end line numbers
///              (1-based, including the starting and closing region marker lines of this region). For a _half-opened region_ the end line number is `none`.
/// - `line_count`: An integer representing the number of lines in the text.
///
/// There are currently no guarantees about the order of regions in the `regions` dictionary.
///
///
/// -> dictionary
#let scan_regions_ll(
  /// Input text to process. -> str
  text,
  /// A *line classifier* is a function that processes a single line and returns an _array of region closers_ or `none`.
  ///
  /// It takes a single `str` as a positional parameter for each line to process and returns one of the following.
  ///
  /// / `none`: Indicates that the line is a _regular line_.
  /// / `array`: Indicates that the line is a _region marker line_.
  ///            This array contains zero or more _region closers_ for each region started at this line.
  ///            A line classifier *must return an array for all region marker lines*, even if these do not start any regions.
  ///            This is required as only those lines are passed to the region closers to determine whether they close a region.
  ///
  /// A *region closer* is a function with the same parameter signature and the following return values.
  /// It is called for each subsequent _region marker line_ until it closes the region.
  /// If the end of the input text is reached and the region is still not closed, the _region closer_ is called with `none` as input.
  ///
  /// / `none`: Indicates that the line does not close the current region.
  ///           If `none` is returned when the input was `none`, the region is discarded.
  /// / `any`: Any non-`none` value closes the region at this line and associates the region with the returned data.
  ///          If this is returned when the input is `none`, the region is stored as a _half-opened region_.
  ///
  /// -> function
  line_classifier,
) = {
  
}