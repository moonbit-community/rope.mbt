///|
/// Tests for the Rope data structure
test "rope_new_empty" {
  let rope = Rope::new()
  inspect(rope.len_chars(), content="0")
  inspect(rope.len_utf16_cu(), content="0")
  inspect(rope.len_lines(), content="1")
  inspect(rope.rope_is_empty(), content="true")
}

///|
test "rope_from_string_basic" {
  let rope = Rope::from_string("Hello, World!")
  inspect(rope.len_chars(), content="13")
  inspect(rope.len_utf16_cu(), content="13")
  inspect(rope.len_lines(), content="1")
  inspect(rope.rope_is_empty(), content="false")
  inspect(rope.rope_to_string(), content="Hello, World!")
}

///|
test "rope_from_string_with_unicode" {
  let rope = Rope::from_string("Hello, 世界!")
  inspect(rope.len_chars(), content="10")
  inspect(rope.len_utf16_cu(), content="10")
  inspect(rope.rope_to_string(), content="Hello, 世界!")
}

///|
test "rope_from_string_with_newlines" {
  let rope = Rope::from_string("Hello\nWorld\n!")
  inspect(rope.len_chars(), content="13")
  inspect(rope.len_lines(), content="3")
  inspect(rope.rope_to_string(), content="Hello\nWorld\n!")
}

///|
test "rope_char_at_basic" {
  let rope = Rope::from_string("Hello")
  inspect(rope.rope_char_at(0), content="72") // 'H'
  inspect(rope.rope_char_at(4), content="111") // 'o'
}

///|
test "rope_char_to_utf16_cu" {
  let rope = Rope::from_string("Hello")
  inspect(rope.char_to_utf16_cu(0), content="0")
  inspect(rope.char_to_utf16_cu(4), content="4")
  inspect(rope.char_to_utf16_cu(5), content="5")
}

///|
test "rope_utf16_cu_to_char" {
  let rope = Rope::from_string("Hello")
  inspect(rope.utf16_cu_to_char(0), content="0")
  inspect(rope.utf16_cu_to_char(4), content="4")
  inspect(rope.utf16_cu_to_char(5), content="5")
}

///|
test "rope_line_operations" {
  let rope = Rope::from_string("Line 1\nLine 2\nLine 3")
  inspect(rope.len_lines(), content="3")
  inspect(rope.line_to_char(0), content="0")
  inspect(rope.line_to_char(1), content="7")
  inspect(rope.line_to_char(2), content="14")
  inspect(rope.char_to_line(0), content="0")
  inspect(rope.char_to_line(7), content="1")
  inspect(rope.char_to_line(14), content="2")
  inspect(rope.line(0), content="Line 1\n")
  inspect(rope.line(1), content="Line 2\n")
  inspect(rope.line(2), content="Line 3")
}

///|
test "rope_insert_basic" {
  let rope = Rope::from_string("Hello World")
  let new_rope = rope.insert(5, ", Beautiful")
  inspect(new_rope.rope_to_string(), content="Hello, Beautiful World")
  inspect(new_rope.len_chars(), content="22")
}

///|
test "rope_insert_at_beginning" {
  let rope = Rope::from_string("World")
  let new_rope = rope.insert(0, "Hello ")
  inspect(new_rope.rope_to_string(), content="Hello World")
}

///|
test "rope_insert_at_end" {
  let rope = Rope::from_string("Hello")
  let new_rope = rope.insert(5, " World")
  inspect(new_rope.rope_to_string(), content="Hello World")
}

///|
test "rope_slice_basic" {
  let rope = Rope::from_string("Hello, World!")
  let slice = rope.slice(0, 5)
  inspect(slice.rope_to_string(), content="Hello")
  let slice2 = rope.slice(7, 12)
  inspect(slice2.rope_to_string(), content="World")
}

///|
test "rope_append" {
  let rope1 = Rope::from_string("Hello")
  let rope2 = Rope::from_string(" World")
  let combined = rope1.rope_append(rope2)
  inspect(combined.rope_to_string(), content="Hello World")
  inspect(combined.len_chars(), content="11")
}

///|
test "rope_split_at" {
  let rope = Rope::from_string("Hello World")
  let (left, right) = rope.split_at(5)
  inspect(left.rope_to_string(), content="Hello")
  inspect(right.rope_to_string(), content=" World")
}

///|
test "rope_remove" {
  let rope = Rope::from_string("Hello, Beautiful World!")
  let new_rope = rope.remove(5, 17)
  inspect(new_rope.rope_to_string(), content="HelloWorld!")
}

///|
test "rope_empty_operations" {
  let rope = Rope::new()
  let with_text = rope.insert(0, "Hello")
  inspect(with_text.rope_to_string(), content="Hello")
  let empty_again = with_text.remove(0, 5)
  inspect(empty_again.rope_is_empty(), content="true")
}

///|
test "str_utils_count_chars" {
  inspect(count_chars("Hello"), content="5")
  inspect(count_chars("Hello 世界"), content="8")
  inspect(count_chars(""), content="0")
}

///|
test "str_utils_count_line_breaks" {
  inspect(count_line_breaks("Hello"), content="0")
  inspect(count_line_breaks("Hello\nWorld"), content="1")
  inspect(count_line_breaks("Line1\nLine2\nLine3"), content="2")
  inspect(count_line_breaks("Line1\r\nLine2\rLine3"), content="2")
}

///|
test "str_utils_char_utf16_conversion" {
  let text = "Hello"
  inspect(char_to_utf16_cu_idx(text, 0), content="0")
  inspect(char_to_utf16_cu_idx(text, 5), content="5")
  inspect(utf16_cu_to_char_idx(text, 0), content="0")
  inspect(utf16_cu_to_char_idx(text, 5), content="5")
}

///|
test "str_utils_line_conversion" {
  let text = "Line1\nLine2\nLine3"
  inspect(char_to_line_idx(text, 0), content="0")
  inspect(char_to_line_idx(text, 6), content="1")
  inspect(char_to_line_idx(text, 12), content="2")
  inspect(line_to_char_idx(text, 0), content="0")
  inspect(line_to_char_idx(text, 1), content="6")
  inspect(line_to_char_idx(text, 2), content="12")
}
