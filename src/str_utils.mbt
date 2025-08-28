/// String utility functions for Rope operations
/// These functions handle UTF-16 strings as used by MoonBit

///|
/// Count the number of Unicode characters in a string
/// In MoonBit, this is simpler since String already stores UTF-16
pub fn count_chars(text : String) -> Int {
  // In MoonBit, we need to iterate through characters to handle surrogate pairs
  let mut count = 0
  for i = 0; i < text.length(); i = i + 1 {
    let ch_code = text[i]
    // Skip low surrogates (they are counted with their high surrogate)
    if ch_code < 0xDC00 || ch_code > 0xDFFF {
      count = count + 1
    }
  }
  count
}

///|
/// Count the number of line breaks in a string
pub fn count_line_breaks(text : String) -> Int {
  let mut count = 0
  let mut i = 0
  while i < text.length() {
    let ch_code = text[i]
    if ch_code == '\n'.to_int() {
      count = count + 1
    } else if ch_code == '\r'.to_int() {
      count = count + 1
      // Skip CRLF pairs - don't count LF after CR
      if i + 1 < text.length() && text[i + 1] == '\n'.to_int() {
        i = i + 1
      }
    }
    i = i + 1
  }
  count
}

///|
/// Convert character index to UTF-16 code unit index
pub fn char_to_utf16_cu_idx(text : String, char_idx : Int) -> Int {
  if char_idx <= 0 {
    return 0
  }
  let mut cu_idx = 0
  let mut char_count = 0
  while cu_idx < text.length() && char_count < char_idx {
    let ch_code = text[cu_idx]
    // Check if this is a high surrogate
    if ch_code >= 0xD800 && ch_code <= 0xDBFF {
      // Skip the low surrogate as well
      cu_idx = cu_idx + 2
    } else {
      cu_idx = cu_idx + 1
    }
    char_count = char_count + 1
  }
  cu_idx
}

///|
/// Convert UTF-16 code unit index to character index
pub fn utf16_cu_to_char_idx(text : String, utf16_idx : Int) -> Int {
  if utf16_idx <= 0 {
    return 0
  }
  let mut char_count = 0
  let mut i = 0
  while i < utf16_idx && i < text.length() {
    let ch_code = text[i]
    // Skip low surrogates (they are counted with their high surrogate)
    if ch_code < 0xDC00 || ch_code > 0xDFFF {
      char_count = char_count + 1
    }
    i = i + 1
  }
  char_count
}

///|
/// Convert character index to line index
pub fn char_to_line_idx(text : String, char_idx : Int) -> Int {
  if char_idx <= 0 {
    return 0
  }
  let target_utf16_idx = char_to_utf16_cu_idx(text, char_idx)
  let mut line_count = 0
  let mut i = 0
  while i < target_utf16_idx && i < text.length() {
    let ch_code = text[i]
    if ch_code == '\n'.to_int() {
      line_count = line_count + 1
    } else if ch_code == '\r'.to_int() {
      line_count = line_count + 1
      // Skip CRLF pairs
      if i + 1 < text.length() && text[i + 1] == '\n'.to_int() {
        i = i + 1
      }
    }
    i = i + 1
  }
  line_count
}

///|
/// Convert line index to character index
pub fn line_to_char_idx(text : String, line_idx : Int) -> Int {
  if line_idx <= 0 {
    return 0
  }
  let mut current_line = 0
  let mut i = 0
  while i < text.length() && current_line < line_idx {
    let ch_code = text[i]
    if ch_code == '\n'.to_int() {
      current_line = current_line + 1
      if current_line == line_idx {
        return utf16_cu_to_char_idx(text, i + 1)
      }
    } else if ch_code == '\r'.to_int() {
      current_line = current_line + 1
      if current_line == line_idx {
        // Handle CRLF
        if i + 1 < text.length() && text[i + 1] == '\n'.to_int() {
          return utf16_cu_to_char_idx(text, i + 2)
        } else {
          return utf16_cu_to_char_idx(text, i + 1)
        }
      }
      // Skip CRLF pairs when counting
      if i + 1 < text.length() && text[i + 1] == '\n'.to_int() {
        i = i + 1
      }
    }
    i = i + 1
  }

  // If we reach here, return the character count of the entire string
  count_chars(text)
}

///|
/// Get character at character index (not UTF-16 index)
pub fn char_at(text : String, char_idx : Int) -> Int {
  let utf16_idx = char_to_utf16_cu_idx(text, char_idx)
  if utf16_idx >= text.length() {
    abort("Character index out of bounds")
  }
  text[utf16_idx]
}

///|
/// Check if a character is a line break
pub fn is_line_break(ch_code : Int) -> Bool {
  ch_code == '\n'.to_int() || ch_code == '\r'.to_int()
}

///|
/// Get the length of a line starting at the given character index
pub fn line_length_from_char(text : String, start_char_idx : Int) -> Int {
  let start_utf16 = char_to_utf16_cu_idx(text, start_char_idx)
  let mut i = start_utf16
  let mut char_count = 0
  while i < text.length() {
    let ch_code = text[i]
    if is_line_break(ch_code) {
      break
    }

    // Count characters, not UTF-16 code units
    if ch_code < 0xDC00 || ch_code > 0xDFFF {
      char_count = char_count + 1
    }
    i = i + 1
  }
  char_count
}

///|
/// Check if string ends with a line break
pub fn ends_with_line_break(text : String) -> Bool {
  if text.length() == 0 {
    return false
  }
  let last_char_code = text[text.length() - 1]
  is_line_break(last_char_code)
}

///|
/// Find the start of the last line in the text
pub fn last_line_start_char_idx(text : String) -> Int {
  if text.length() == 0 {
    return 0
  }
  let mut i = text.length() - 1

  // Skip trailing line break if present
  if is_line_break(text[i]) {
    if i > 0 && text[i] == '\n'.to_int() && text[i - 1] == '\r'.to_int() {
      i = i - 1 // Skip CRLF
    }
    if i > 0 {
      i = i - 1
    }
  }

  // Find the previous line break
  while i > 0 {
    let ch_code = text[i]
    if is_line_break(ch_code) {
      return utf16_cu_to_char_idx(text, i + 1)
    }
    i = i - 1
  }
  0
}
