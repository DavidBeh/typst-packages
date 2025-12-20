

/// Splits the input text into an array of lines based on newline characters. Supports `\r\n`, `\n`, and `\r` as line endings.
///
#let split-lines(
  /// -> str
  text
) = {
  return text.split(regex("\r\n|\n|\r"))
}