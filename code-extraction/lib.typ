// LTeX: enabled=false

// Original implementation.

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/oxifmt:1.0.0": strfmt
#show: codly-init.with()

#let _csparse_ = `^//\s*@region\s+(.*?)\s*$`.text

/// Joins raws and strings
///
/// - args (array): array of raw or str
/// -> str
#let join(..args) = {
  if type(args) == raw or type(args) == content {
    return args.text
  }

  array.fold(args.pos(), "", (a, b) => {
    if type(b) == str {
      a + b
    } else {
      a + b.at("text")
    }
  })
}


/// Escapes a string for regex. E.g. * -> \*
///
/// - raw_or_str (str, raw):
/// -> str
#let escape(raw_or_str) = {
  let text = if (type(raw_or_str) == raw) {
    raw_or_str = raw_or_str.text
  } else {
    raw_or_str
  }
  assert(type(raw_or_str) == str)
  // Matches regex special characters: \ . + * ? ( ) | [ ] { } ^ $ -
  // We use a regex to find them and a function to prepend a backslash.
  text.replace(
    regex("[\\\\.+*?()|\\[\\]{}^$\-]"),
    m => "\\" + m.text,
  )
}


// ex: ^ *// *@region +(.*?) *$

#let region_pattern_part = `@region +(.*?)`
//  `//`
#let get_reg_lc_pat(patternstr) = join(`^ *`, patternstr, ` *`, region_pattern_part, ` *$`)

// `/\*`    `\*/`
#let get_reg_bc2_pat(start, end) = join(`^ *`, start, ` *`, region_pattern_part, ` *`, end, ` *$`)

#let get_tag_pat(tag) = join(`\b((?:start)|(?:end)):`, tag, `\b`)


#let name(params) = output

/// - line (str)
/// - pattern (str): for example result of construct_bc_pattern
/// -> str|none
#let try_get_region(line, pattern) = {
  let result = str.match(line, regex(pattern))
  if (result == none) {
    return none
  }
  return result.at("captures").at(0)
}

/// pattern
///
/// - region (str): the part with "start:mytag end:myothertag" ...
/// - tag (str): the tag
/// -> str|none: returns start, end or none
#let try_get_status(region, tag_pattern) = {
  let match_result = str.match(region, regex(tag_pattern))
  if (match_result == none) {
    return none
  }
  return match_result.at("captures").at(0)
}




#let r_is_open(arr) = {
  assert(type(arr) == array)
  let last = array.last(arr, default: (none, 1))
  last.at(1) == none
}

#let r_end(arr, snd) = {
  assert(r_is_open(arr))
  assert(snd != none)

  arr.last() = (arr.last().at(0), snd)
  return arr
}

#let r_start(arr, fst) = {
  assert(not r_is_open(arr))
  assert(fst != none)

  arr.push((fst, none))
  return arr
}

/// returns lines and ranges
///
/// - lines (array): array of str
/// - tag (str,none): str or none if all except regions should be included
/// - line_patterns (array): array of str, patterns that match the whole region comment, e.g. created with get_reg_bc2_pat
/// -> dictionary: returns
#let process_lines(lines, tag, line_patterns) = {
  let status = "end"
  if tag == none {
    status = "start"
  } else {
    assert.eq(type(tag), str)
  }

  let num = 0

  let ranges = ()
  let skips = ()

  let line = ""
  /// -> str
  for _v in lines {
    line = _v
    num += 1


    /// -> str, none: str if is region line, none if is regular
    let region = none

    for line_pattern in line_patterns {
      assert(type(line_pattern) == str, message: "must be string")
      region = try_get_region(line, line_pattern)
      if type(region) == str {
        // skip tag if not specified.
        if (tag != none) {
          assert.eq(type(tag), str)
          let tag_pattern = get_tag_pat(tag)
          let my_tag_status = try_get_status(region, tag_pattern)
          if type(my_tag_status) == str {
            status = my_tag_status
          }
        }
        break
      }
    }

    let is_region = region != none

    if status == "start" {
      if not is_region and not r_is_open(ranges) {
        ranges = r_start(ranges, num)
        if r_is_open(skips) {
          skips = r_end(skips, 0)
        }
      }
      if is_region and r_is_open(ranges) {
        ranges = r_end(ranges, num - 1)
      }
    }

    if status == "end" {
      if r_is_open(ranges) {
        ranges = r_end(ranges, num - 1)
      }
      if not is_region and not r_is_open(skips) {
        skips = r_start(skips, num)
      }
    }
  } // end loop

  if r_is_open(skips) {
    skips = r_end(skips, 0)
  }


  if tag == none {
    if r_is_open(ranges) {
      ranges = r_end(ranges, num)
    }
    // if tag is unset it should be impossible to end with an open range
    // this above is wrong
    //assert.eq(r_is_open(ranges), false)
  }

  let open_r_num = none
  if status == "start" and r_is_open(ranges) {
    (open_r_num, _) = ranges.pop()
  }

  assert.eq(r_is_open(ranges), false)

  /*
  if r_is_open(ranges) {
    ranges = r_end(ranges, num)
  }*/

  return (
    ranges: ranges,
    skips: skips,
    open_r_num: open_r_num
  )
}


#let get_extension(path) = {
  let match = str.match(path, regex("\.([^.]+)$"))
  if (match == none) {
    return none
  }
  return match.captures.at(0)
}

#let get_lang_for_extension(ext) = {
  let lang_dict = (
    cs: "cs",
    // alias: csproj -> xml; lang: csproj
    // label, alias_right_lang, pattern_key
    csproj: ("csproj", "html", "xml"),
    props: ("proj", "html", "xml"),
    shproj: ("shproj", "html", "xml"),
    razor: ("razor", "xml", "razor"),
    razor_cs: ("razor", "cs", "razor"),
    json: "json",
    yaml: "yaml",
    yml: "yaml",
    ps1: "ps1",
    dockerfile: "dockerfile"
  )
  let res = dictionary.at(lang_dict, ext, default: none)
  if type(res) == array {
    return (
      label: res.at(0),
      alias_right_lang: res.at(1),
      pattern_key: res.at(2),
    )
  }
  return (
    label: res,
    alias_right_lang: res,
    pattern_key: res,
  )
}

#let get_patterns_for_lang(lang) = {
  assert(type(lang) == str)
  let dict = (
    cs: (("//", get_reg_lc_pat), ("/*", "*/", get_reg_bc2_pat)),
    razor: (("//", get_reg_lc_pat), ("@*", "*@", get_reg_bc2_pat)),
    yaml: (("#", get_reg_lc_pat),),
    ps1: (("#", get_reg_lc_pat),),
    dockerfile: (("#", get_reg_lc_pat),),
    xml: (("<!--", "-->", get_reg_bc2_pat),),
  )
  let entries = dict.at(lang)
  let ret = ()
  for (..args, fun) in entries {
    let escaped_args = array.map(args, escape)
    ret.push(fun(..escaped_args))
  }
  return ret
}

#let get_path_display_name(path) = {
  assert.eq(type(path), str)

  // convert backslashes to forwards slahes
  path = str.replace(path, "\\", "/")

  let segements = str.split(path, "|")
  // no more than 2 pipe-symbols |
  assert(segements.len() <= 2)
  let name = segements.at(1, default: none)
  if (name == none) {
    // no pipe symbol | found, normalize path:
    // trim leading "./"'s
    name = str.trim(path, "./", at: alignment.start)
  }

  return name
}

///
///
/// - path (str): The path
/// -> content
#let includefile(
  path,
  tag: none,
  header: none,
  name: auto,
  lang: auto, // actually the ext key for get_lang_for_extension
  pattern_key: auto,
  label: auto,
  footer: auto
) = {
  assert.eq(type(path), str)

  if name == auto {
    name = get_path_display_name(path)
  }

  // remove pipe symbols
  path = str.replace(path, "|", "")

  if lang == auto {
    // auto name (must succeed)
    lang = get_extension(path)
    //lang = get_lang_for_extension(ext)
    //assert.ne(name,none)
  }

  let pattern_str = ""
  let alias = ""


  let (label: label_2, alias_right_lang, pattern_key:pattern_key_2) = get_lang_for_extension(lang)
  if (label == auto) {
    label = label_2
  }
  if pattern_key == auto {
    pattern_key = pattern_key_2
  }

  let aliases_dict = (:)
  aliases_dict.insert(label, alias_right_lang)


  let file = read(path)
  let lines = str.split(file, regex(join(`\r\n|\r|\n`)))
  let patterns = get_patterns_for_lang(pattern_key)
  let (ranges, skips, open_r_num) = process_lines(lines, tag, patterns)

  if (ranges == ()) {
    panic(strfmt(
      "No ranges to include for {0} with tag {1}",
      path,
      tag,
    ))
  }

  if open_r_num != none {
    panic(strfmt(
      "Included file {0} ends with open group {1} for tag {2}",
      path,
      (open_r_num, none),
      tag,
    ))
  }

  footer = if footer == auto {
    [#name]
  } else if type(footer) == function {
    let (first, _) = array.first(ranges)
    let (_, last) = array.last(ranges)

    let args = arguments(first, last, name)
    footer(..args)
  }

  local(
    raw(file, block: true, lang: label),
 //   footer: footer,
    header: header,
    ranges: ranges,
 //   skips: skips,
 //   number-format: none,
    languages: codly-languages,
    aliases: aliases_dict,
  )
}


