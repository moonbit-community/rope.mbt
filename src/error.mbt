/// Error types for Rope operations, based on Ropey's Error enum

///|
/// Result type for Rope operations
pub type RopeResult[T] = Result[T, RopeError]

///|
/// Error types that can occur during Rope operations  
pub enum RopeError {
  /// Indicates that the passed character index was out of bounds
  /// Contains the index attempted and the actual length in characters
  CharIndexOutOfBounds(Int, Int)
  /// Indicates that the passed UTF-16 code unit index was out of bounds
  /// Contains the index attempted and the actual length in UTF-16 code units
  Utf16IndexOutOfBounds(Int, Int)
  /// Indicates that the passed line index was out of bounds
  /// Contains the index attempted and the actual number of lines
  LineIndexOutOfBounds(Int, Int)
  /// Indicates that a reversed range (end < start) was encountered
  /// Contains the start and end indices
  CharRangeInvalid(Int, Int)
  /// Indicates that the passed range was partially or fully out of bounds
  /// Contains the start, end, and rope length
  CharRangeOutOfBounds(Int, Int, Int)
}

///|
/// Convert RopeError to String for display
pub fn RopeError::to_string(self : RopeError) -> String {
  match self {
    CharIndexOutOfBounds(index, len) =>
      "Character index out of bounds: char index \{index}, Rope char length \{len}"
    Utf16IndexOutOfBounds(index, len) =>
      "UTF-16 index out of bounds: utf16 index \{index}, Rope utf16 length \{len}"
    LineIndexOutOfBounds(index, len) =>
      "Line index out of bounds: line index \{index}, Rope line count \{len}"
    CharRangeInvalid(start, end) =>
      "Invalid char range \{start}..\{end}: start must be <= end"
    CharRangeOutOfBounds(start, end, len) =>
      "Character range out of bounds: char range \{start}..\{end}, Rope char length \{len}"
  }
}

///|
/// Check if a character index is valid
pub fn check_char_index(char_idx : Int, rope_len : Int) -> RopeResult[Unit] {
  if char_idx < 0 || char_idx >= rope_len {
    Err(CharIndexOutOfBounds(char_idx, rope_len))
  } else {
    Ok(())
  }
}

///|
/// Check if a character index is valid for insertion (can be equal to length)
pub fn check_char_index_for_insert(
  char_idx : Int,
  rope_len : Int,
) -> RopeResult[Unit] {
  if char_idx < 0 || char_idx > rope_len {
    Err(CharIndexOutOfBounds(char_idx, rope_len))
  } else {
    Ok(())
  }
}

///|
/// Check if a UTF-16 index is valid
pub fn check_utf16_index(
  utf16_idx : Int,
  rope_utf16_len : Int,
) -> RopeResult[Unit] {
  if utf16_idx < 0 || utf16_idx >= rope_utf16_len {
    Err(Utf16IndexOutOfBounds(utf16_idx, rope_utf16_len))
  } else {
    Ok(())
  }
}

///|
/// Check if a line index is valid
pub fn check_line_index(
  line_idx : Int,
  rope_line_count : Int,
) -> RopeResult[Unit] {
  if line_idx < 0 || line_idx >= rope_line_count {
    Err(LineIndexOutOfBounds(line_idx, rope_line_count))
  } else {
    Ok(())
  }
}

///|
/// Check if a character range is valid
pub fn check_char_range(
  start : Int,
  end : Int,
  rope_len : Int,
) -> RopeResult[Unit] {
  if start > end {
    Err(CharRangeInvalid(start, end))
  } else if start < 0 || end > rope_len {
    Err(CharRangeOutOfBounds(start, end, rope_len))
  } else {
    Ok(())
  }
}
