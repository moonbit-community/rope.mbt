//|

///|
/// A UTF-16 text rope for efficient string operations
/// 
/// Rope is a tree-based data structure optimized for efficient insertion,
/// deletion, and concatenation of large strings. All operations work with
/// Unicode character indices rather than UTF-16 code unit indices.
pub struct Rope {
  root : Node
}

///|
/// Create a new empty Rope
pub fn Rope::new() -> Rope {
  { root: Node::new() }
}

///|
/// Create a Rope from a string
pub fn Rope::from_string(text : String) -> Rope {
  if text.length() <= MAX_BYTES {
    { root: Node::new_leaf(text) }
  } else {
    // For large strings, split them across multiple nodes
    let mid = text.length() / 2
    let left = text.substring(start=0, end=mid)
    let right = text.substring(start=mid, end=text.length())
    let children = NodeChildren::new()
    children.push(TextInfo::from_string(left), Node::new_leaf(left))
    children.push(TextInfo::from_string(right), Node::new_leaf(right))
    { root: Node::new_internal(children) }
  }
}

///|
/// Get the total number of UTF-16 code units in the rope
pub fn Rope::len_utf16_cu(self : Rope) -> Int {
  self.root.utf16_cu_count().to_int()
}

///|
/// Get the total number of Unicode characters in the rope  
pub fn Rope::len_chars(self : Rope) -> Int {
  self.root.char_count().to_int()
}

///|
/// Get the total number of lines in the rope
pub fn Rope::len_lines(self : Rope) -> Int {
  (self.root.line_break_count() + 1UL).to_int()
}

///|
/// Check if the rope is empty
pub fn Rope::rope_is_empty(self : Rope) -> Bool {
  self.len_chars() == 0
}

///|
/// Get the character at the given character index (returns character code)
pub fn Rope::rope_char_at(self : Rope, char_idx : Int) -> Int {
  match self.try_char_at(char_idx) {
    Ok(c) => c
    Err(err) => abort(err.to_string())
  }
}

///|
/// Safe version of char_at that returns a Result
pub fn Rope::try_char_at(self : Rope, char_idx : Int) -> RopeResult[Int] {
  match check_char_index(char_idx, self.len_chars()) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let (chunk_text, acc_info) = self.root.get_chunk_at_char(char_idx.to_uint64())
  let chunk_char_idx = char_idx - acc_info.char_count_int()
  Ok(char_at(chunk_text, chunk_char_idx))
}

///|
/// Convert character index to UTF-16 code unit index
pub fn Rope::char_to_utf16_cu(self : Rope, char_idx : Int) -> Int {
  if char_idx > self.len_chars() {
    abort("Character index out of bounds")
  }
  if char_idx == self.len_chars() {
    return self.len_utf16_cu()
  }
  let (chunk_text, acc_info) = self.root.get_chunk_at_char(char_idx.to_uint64())
  let chunk_char_idx = char_idx - acc_info.char_count_int()
  let chunk_utf16_idx = char_to_utf16_cu_idx(chunk_text, chunk_char_idx)
  acc_info.utf16_cu_count_int() + chunk_utf16_idx
}

///|
/// Convert UTF-16 code unit index to character index
pub fn Rope::utf16_cu_to_char(self : Rope, utf16_cu_idx : Int) -> Int {
  if utf16_cu_idx > self.len_utf16_cu() {
    abort("UTF-16 code unit index out of bounds")
  }
  if utf16_cu_idx == self.len_utf16_cu() {
    return self.len_chars()
  }
  let (chunk_text, acc_info) = self.root.get_chunk_at_utf16_cu(
    utf16_cu_idx.to_uint64(),
  )
  let chunk_utf16_idx = utf16_cu_idx - acc_info.utf16_cu_count_int()
  let chunk_char_idx = utf16_cu_to_char_idx(chunk_text, chunk_utf16_idx)
  acc_info.char_count_int() + chunk_char_idx
}

///|
/// Convert character index to line index
pub fn Rope::char_to_line(self : Rope, char_idx : Int) -> Int {
  if char_idx > self.len_chars() {
    abort("Character index out of bounds")
  }
  let (chunk_text, acc_info) = self.root.get_chunk_at_char(char_idx.to_uint64())
  let chunk_char_idx = char_idx - acc_info.char_count_int()
  let chunk_line_idx = char_to_line_idx(chunk_text, chunk_char_idx)
  acc_info.line_break_count_int() + chunk_line_idx
}

///|
/// Convert line index to character index
pub fn Rope::line_to_char(self : Rope, line_idx : Int) -> Int {
  if line_idx > self.len_lines() {
    abort("Line index out of bounds")
  }
  if line_idx == self.len_lines() {
    return self.len_chars()
  }
  let (chunk_text, acc_info) = self.root.get_chunk_at_line_break(
    line_idx.to_uint64(),
  )
  let chunk_line_idx = line_idx - acc_info.line_break_count_int()
  let chunk_char_idx = line_to_char_idx(chunk_text, chunk_line_idx)
  acc_info.char_count_int() + chunk_char_idx
}

///|
/// Insert text at the given character index
pub fn Rope::insert(self : Rope, char_idx : Int, text : String) -> Rope {
  if char_idx > self.len_chars() {
    abort("Character index out of bounds")
  }
  { root: self.root.insert_text(char_idx.to_uint64(), text) }
}

///|
/// Get a slice of the rope from start_char to end_char (exclusive)
pub fn Rope::slice(self : Rope, start_char : Int, end_char : Int) -> Rope {
  if start_char > end_char {
    abort("Invalid range: start > end")
  }
  if end_char > self.len_chars() {
    abort("End index out of bounds")
  }

  // This is a simplified implementation
  // In practice, this would return a RopeSlice that shares data with the original
  let text = self.rope_to_string()
  let start_utf16 = char_to_utf16_cu_idx(text, start_char)
  let end_utf16 = char_to_utf16_cu_idx(text, end_char)
  let slice_text = text.substring(start=start_utf16, end=end_utf16)
  Rope::from_string(slice_text)
}

///|
/// Convert the entire rope to a string
pub fn Rope::rope_to_string(self : Rope) -> String {
  self.root.node_to_string()
}

///|
/// Get a line by its index
pub fn Rope::line(self : Rope, line_idx : Int) -> String {
  if line_idx >= self.len_lines() {
    abort("Line index out of bounds")
  }
  let start_char = self.line_to_char(line_idx)
  let end_char = if line_idx == self.len_lines() - 1 {
    self.len_chars()
  } else {
    self.line_to_char(line_idx + 1)
  }
  self.slice(start_char, end_char).rope_to_string()
}

///|
/// Append another rope to this one
pub fn Rope::rope_append(self : Rope, other : Rope) -> Rope {
  if self.rope_is_empty() {
    other
  } else if other.rope_is_empty() {
    self
  } else {
    { root: self.root.node_append(other.root) }
  }
}

///|
/// Split the rope at the given character index
/// Returns a tuple of (left_part, right_part)
pub fn Rope::split_at(self : Rope, char_idx : Int) -> (Rope, Rope) {
  if char_idx > self.len_chars() {
    abort("Character index out of bounds")
  }
  if char_idx == 0 {
    (Rope::new(), self)
  } else if char_idx == self.len_chars() {
    (self, Rope::new())
  } else {
    let left = self.slice(0, char_idx)
    let right = self.slice(char_idx, self.len_chars())
    (left, right)
  }
}

///|
/// Remove text in the given character range
pub fn Rope::remove(self : Rope, start_char : Int, end_char : Int) -> Rope {
  if start_char > end_char {
    abort("Invalid range: start > end")
  }
  if end_char > self.len_chars() {
    abort("End index out of bounds")
  }
  if start_char == 0 && end_char == self.len_chars() {
    return Rope::new()
  }
  let left = if start_char > 0 {
    self.slice(0, start_char)
  } else {
    Rope::new()
  }
  let right = if end_char < self.len_chars() {
    self.slice(end_char, self.len_chars())
  } else {
    Rope::new()
  }
  left.rope_append(right)
}
