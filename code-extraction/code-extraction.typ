#import "documentation.typ": print_docs
#import "string-utils.typ": split-lines
//#import "@preview/t4t:0.4.3": assert
/// A _line classifier / region closer_ that returns `none` if no pattern matches, or calls `next` with the first regex capture group text.
///
/// -> function(str)
#let pattern_filter_stage(
  /// A array of regex patterns. Each pattern must have a capture group. -> array of str
  patterns,
  /// A function with the same signature as @resolve_regions.region_opener.
  /// This function is called when a pattern matches. It takes the captured text of the first capture group as input.
  /// Pattern matching is skipped if `patterns` is `none`, in which case `next` is called with `none` as input.
  ///
  /// -> function
  next,
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

/// Returns an array where each item corresponds to a line in `lines`.
///
/// `none` is returned for regular lines, and for region marker lines the result of `marker_classifier` is returned.
///
/// -> array
#let scan_marker_lines(
  /// -> array
  lines,
  /// A function that determines for each line, whether it is a region marker line. Takes a single `str` as input and returns
  /// / `none`: for regular lines
  /// / `any`: any non-`none` value as the data associated with a region marker lines,
  ///
  /// -> function
  marker_classifier,
) = {
  return lines.map(marker_classifier)
}

/// Low level function to scan regions in text.
///
/// Returns an array where each item represents a region as a dictionary with the following keys:
///
/// / `data`: The data associated with this region as returned by the _region closer_.
/// / `start`: The line number where the region was opened on.
/// / `end`: The line number on which the region was closed. For a _half-opened region_ the end line number is `none`.
///
/// Line numbers one-based and specified as `int`.
///
/// -> array
#let resolve_regions(
  /// Input array where each item represents a line. Usually created with @scan_marker_lines. The type of each item is:
  ///
  /// / `none`: for _regular lines_, which are not processed with `region_opener`
  /// / `any`: for _region marker lines_, which are processed with `region_opener`
  ///
  /// -> array
  lines,
  /// A *region opener* is a function that processes a single _region marker line_ and returns an array of _region closers_.
  ///
  /// Each non-`none` item in `lines` is passed as the only positional parameter.
  ///
  /// It must return an array of zero or more _region closers_ for each region started at this line.
  ///
  /// A *region closer* is a function with the same parameter signature and the following return values.
  /// It is called for each subsequent _region marker line_ until it closes the region.
  ///
  /// / `none`: Indicates that the line does not close the current region.
  /// / `any`: Any non-`none` value closes the region at this line and associates the region with the returned data.
  ///          If this is returned when the input is `none`, the region is stored as a _half-opened region_.
  ///
  /// If the end of the input text is reached and the region is still not closed, the _region closer_ is called with `none` as input.
  /// The region will then be stored as a _half-opened region_, regardless of the return value.
  ///
  /// -> function
  region_opener,
) = {
  assert.eq(type(lines), array)
  // -> array
  let lines = lines

  // return values
  let regions = ()

  // stores tuples: (line_num, line) where line != none
  let numbered_lines = lines.enumerate(start: 1).filter(((_, line)) => line != none)
  // stores lines tested against closer
  let next_lines = numbered_lines

  for (start_num /*returned as `start`*/, start_line) in numbered_lines {
    // only test subsequent lines
    next_lines = next_lines.slice(1)

    let closer_list = region_opener(start_line)
    assert.eq(type(closer_list), array)


    for closer in closer_list {
      assert.eq(type(closer), function)

      // returned as `data`
      let data = none
      // returned as `end`
      let end_num = none

      // Try closing the region for each subsequent line
      for (current_end_num, end_line) in next_lines {
        data = closer(end_line)
        if (data != none) {
          // Region closed
          end_num = current_end_num
          break
        }
      }

      // Last chance to associate the region with data if it is still open post EOF
      if data == none {
        data = closer(none)
      }

      regions.push((
        data: data,
        start: start_num,
        end: end_num,
      ))
    }
  }

  return regions
}

/*
#resolve_regions((1, 2, 3, 4, 2, 6), start => {
  return (
    end => {
      if end == start {
        return end
      }
    },
  )
})
*/

