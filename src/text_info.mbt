///|
/// Text metadata information, similar to Ropey's TextInfo
/// Stores cumulative counts for efficient tree operations
pub struct TextInfo {
  /// Number of UTF-16 code units
  utf16_cu : UInt64
  /// Number of Unicode characters
  chars : UInt64
  /// Number of line breaks
  line_breaks : UInt64
} derive(Eq)

///|
/// Create a new empty TextInfo
pub fn TextInfo::new() -> TextInfo {
  { utf16_cu: 0UL, chars: 0UL, line_breaks: 0UL }
}

///|
/// Create TextInfo from a string
pub fn TextInfo::from_string(text : String) -> TextInfo {
  {
    utf16_cu: text.length().to_uint64(),
    chars: count_chars(text).to_uint64(),
    line_breaks: count_line_breaks(text).to_uint64(),
  }
}

///|
/// Add two TextInfo instances
pub fn TextInfo::op_add(self : TextInfo, other : TextInfo) -> TextInfo {
  {
    utf16_cu: self.utf16_cu + other.utf16_cu,
    chars: self.chars + other.chars,
    line_breaks: self.line_breaks + other.line_breaks,
  }
}

///|
/// Implement Add trait for TextInfo
impl Add for TextInfo with add(self, other) {
  self.op_add(other)
}

///|
/// Implement Sub trait for TextInfo
impl Sub for TextInfo with sub(self, other) {
  self.op_sub(other)
}

///|
/// Subtract two TextInfo instances
pub fn TextInfo::op_sub(self : TextInfo, other : TextInfo) -> TextInfo {
  {
    utf16_cu: self.utf16_cu - other.utf16_cu,
    chars: self.chars - other.chars,
    line_breaks: self.line_breaks - other.line_breaks,
  }
}

///|
/// Convert character count to Int
pub fn TextInfo::char_count_int(self : TextInfo) -> Int {
  self.chars.to_int()
}

///|
/// Convert UTF-16 code unit count to Int  
pub fn TextInfo::utf16_cu_count_int(self : TextInfo) -> Int {
  self.utf16_cu.to_int()
}

///|
/// Convert line break count to Int
pub fn TextInfo::line_break_count_int(self : TextInfo) -> Int {
  self.line_breaks.to_int()
}

///|
/// Check if this TextInfo represents empty text
pub fn TextInfo::is_empty(self : TextInfo) -> Bool {
  self.chars == 0UL
}
