# MoonBit Rope Library

A high-performance UTF-16 text rope implementation for MoonBit, based on the Rust [Ropey](https://github.com/cessen/ropey) library.

## Features

- **Fast Operations**: All operations are O(log N) or better
- **UTF-16 Native**: Designed for MoonBit's UTF-16 string representation
- **Unicode Safe**: All operations work with character indices, not UTF-16 code units
- **Memory Efficient**: Tree-based structure with copy-on-write semantics
- **Line-Aware**: Built-in support for line-based operations

## Basic Usage

### Creating a Rope

```moonbit
test "basic_usage" {
  // Create an empty rope
  let rope = Rope::new()
  inspect(rope.rope_is_empty(), content="true")
  
  // Create a rope from a string
  let rope = Rope::from_string("Hello, World!")
  inspect(rope.len_chars(), content="13")
  inspect(rope.rope_to_string(), content="Hello, World!")
}
```

### Text Information

```moonbit
test "text_info" {
  let rope = Rope::from_string("Hello\nWorld\n!")
  
  // Get various length measurements
  inspect(rope.len_chars(), content="13")        // Number of characters
  inspect(rope.len_utf16_cu(), content="13")     // Number of UTF-16 code units
  inspect(rope.len_lines(), content="3")         // Number of lines
}
```

### Character Operations

```moonbit
test "character_ops" {
  let rope = Rope::from_string("Hello, 世界!")
  
  // Get character at index (returns character code)
  inspect(rope.rope_char_at(0), content="72")    // 'H'
  inspect(rope.rope_char_at(7), content="19990") // '世'
  
  // Convert between character and UTF-16 indices
  inspect(rope.char_to_utf16_cu(7), content="7")
  inspect(rope.utf16_cu_to_char(7), content="7")
}
```

### Text Modification

```moonbit
test "modification" {
  let rope = Rope::from_string("Hello World")
  
  // Insert text at any position
  let rope2 = rope.insert(5, ", Beautiful")
  inspect(rope2.rope_to_string(), content="Hello, Beautiful World")
  
  // Remove text ranges
  let rope3 = rope2.remove(5, 17)  // Remove ", Beautiful"
  inspect(rope3.rope_to_string(), content="HelloWorld")
  
  // Note: Original rope is unchanged (immutable)
  inspect(rope.rope_to_string(), content="Hello World")
}
```

### Line Operations

```moonbit
test "line_ops" {
  let rope = Rope::from_string("Line 1\nLine 2\nLine 3")
  
  // Get line count
  inspect(rope.len_lines(), content="3")
  
  // Convert between character and line indices
  inspect(rope.line_to_char(1), content="7")     // Start of line 1
  inspect(rope.char_to_line(7), content="1")     // Character 7 is on line 1
  
  // Get individual lines
  inspect(rope.line(0), content="Line 1\n")
  inspect(rope.line(1), content="Line 2\n")
  inspect(rope.line(2), content="Line 3")        // Last line without newline
}
```

### Rope Operations

```moonbit
test "rope_ops" {
  let rope1 = Rope::from_string("Hello")
  let rope2 = Rope::from_string(" World")
  
  // Append ropes
  let combined = rope1.rope_append(rope2)
  inspect(combined.rope_to_string(), content="Hello World")
  
  // Split rope at position
  let (left, right) = combined.split_at(5)
  inspect(left.rope_to_string(), content="Hello")
  inspect(right.rope_to_string(), content=" World")
  
  // Create slices
  let slice = combined.slice(0, 5)
  inspect(slice.rope_to_string(), content="Hello")
}
```

## Advanced Usage

### Error Handling

```moonbit
test "error_handling" {
  let rope = Rope::from_string("Hello")
  
  // Safe character access
  match rope.try_char_at(0) {
    Ok(char_code) => inspect(char_code, content="72")  // 'H'
    Err(err) => abort("Unexpected error")
  }
  
  // Out of bounds access returns error
  match rope.try_char_at(10) {
    Ok(_) => abort("Should have failed")
    Err(err) => inspect(err.error_to_string(), content="Character index out of bounds: char index 10, Rope char length 5")
  }
}
```

### Working with Unicode

```moonbit
test "unicode_handling" {
  let rope = Rope::from_string("Hello, 世界! 🌍")
  
  // All operations work with logical characters, not UTF-16 code units
  inspect(rope.len_chars(), content="12")
  
  // Character-based slicing works correctly with Unicode
  let slice = rope.slice(7, 9)  // Extract "世界"
  inspect(slice.rope_to_string(), content="世界")
  
  // Line operations handle Unicode correctly
  let multiline = Rope::from_string("English\n中文\nEmoji🎉")
  inspect(multiline.len_lines(), content="3")
  inspect(multiline.line(1), content="中文\n")
}
```

### Performance Considerations

```moonbit
test "performance_tips" {
  // Large text handling - rope structure scales well
  let large_text = "This is a very long text that would be expensive to manipulate with regular strings...\n".repeat(1000)
  let rope = Rope::from_string(large_text)
  
  // Insertions and deletions are O(log N)
  let modified = rope.insert(100, "INSERTED TEXT")
  
  // Slicing is also O(log N) and shares data where possible
  let slice = rope.slice(0, 1000)
  
  // Multiple operations can be chained efficiently
  let result = rope
    .insert(50, "FIRST")
    .insert(100, "SECOND")
    .remove(200, 300)
    .slice(0, 500)
  
  inspect(result.len_chars() > 0, content="true")
}
```

## String Utilities

The library also provides direct string manipulation utilities:

```moonbit
test "string_utils" {
  // Character counting (handles surrogate pairs correctly)
  inspect(count_chars("Hello 世界"), content="8")
  
  // Line break counting (handles CRLF correctly)
  inspect(count_line_breaks("Line1\r\nLine2\nLine3"), content="2")
  
  // Character/UTF-16 index conversion
  let text = "Hello"
  inspect(char_to_utf16_cu_idx(text, 3), content="3")
  inspect(utf16_cu_to_char_idx(text, 3), content="3")
  
  // Character/line index conversion
  let lines = "Line1\nLine2\nLine3"
  inspect(char_to_line_idx(lines, 6), content="1")
  inspect(line_to_char_idx(lines, 1), content="6")
}
```

## Implementation Details

### UTF-16 Handling

Unlike the original Ropey library which works with UTF-8, this implementation is designed for MoonBit's UTF-16 strings:

- All character indices refer to logical Unicode characters, not UTF-16 code units
- Surrogate pairs are handled correctly and counted as single characters
- Performance is optimized for UTF-16 operations

### Tree Structure

The rope uses a balanced tree structure where:
- Leaf nodes contain actual text (up to ~1KB each)
- Internal nodes contain metadata and child references
- All operations maintain tree balance automatically
- Text info (character count, line count, etc.) is cached in each node

### Line Break Handling

The library recognizes several line break patterns:
- `\n` (LF) - Unix style
- `\r\n` (CRLF) - Windows style (counted as single line break)
- `\r` (CR) - Classic Mac style

### Memory Efficiency

- Copy-on-write semantics mean that cloning ropes is O(1)
- Slicing shares data with the original rope where possible
- Tree rebalancing happens automatically to maintain performance

## API Reference

### Rope Creation
- `Rope::new()` - Create empty rope
- `Rope::from_string(text: String)` - Create rope from string

### Information
- `len_chars()` - Character count
- `len_utf16_cu()` - UTF-16 code unit count  
- `len_lines()` - Line count
- `rope_is_empty()` - Check if empty

### Character Access
- `rope_char_at(index: Int)` - Get character code at index
- `try_char_at(index: Int)` - Safe character access

### Index Conversion
- `char_to_utf16_cu(char_idx: Int)` - Convert character to UTF-16 index
- `utf16_cu_to_char(utf16_idx: Int)` - Convert UTF-16 to character index
- `char_to_line(char_idx: Int)` - Convert character to line index
- `line_to_char(line_idx: Int)` - Convert line to character index

### Text Operations
- `insert(index: Int, text: String)` - Insert text at position
- `remove(start: Int, end: Int)` - Remove text range
- `slice(start: Int, end: Int)` - Create slice
- `rope_append(other: Rope)` - Append another rope
- `split_at(index: Int)` - Split rope at position
- `line(index: Int)` - Get line text

### Conversion
- `rope_to_string()` - Convert entire rope to string

This implementation provides a solid foundation for efficient text manipulation in MoonBit applications, especially those dealing with large documents or requiring frequent text modifications.
