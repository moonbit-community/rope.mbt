///|
/// Node in the Rope tree structure
/// Can be either a leaf node (containing text) or internal node (containing children)
pub enum Node {
  /// Leaf node containing actual text
  Leaf(String)
  /// Internal node containing child nodes
  Internal(NodeChildren)
}

///|
/// Create a new empty leaf node
pub fn Node::new() -> Node {
  Leaf("")
}

///|
/// Create a new empty node (for placeholder purposes)
pub fn Node::new_empty() -> Node {
  Leaf("")
}

///|
/// Create a new leaf node with text
pub fn Node::new_leaf(text : String) -> Node {
  Leaf(text)
}

///|
/// Create a new internal node with children
pub fn Node::new_internal(children : NodeChildren) -> Node {
  Internal(children)
}

///|
/// Check if this is a leaf node
pub fn Node::is_leaf(self : Node) -> Bool {
  match self {
    Leaf(_) => true
    Internal(_) => false
  }
}

///|
/// Check if this is an internal node
pub fn Node::is_internal(self : Node) -> Bool {
  match self {
    Leaf(_) => false
    Internal(_) => true
  }
}

///|
/// Get the text info for this node
pub fn Node::text_info(self : Node) -> TextInfo {
  match self {
    Leaf(text) => TextInfo::from_string(text)
    Internal(children) => children.total_info()
  }
}

///|
/// Get the number of UTF-16 code units in this node
pub fn Node::utf16_cu_count(self : Node) -> UInt64 {
  self.text_info().utf16_cu
}

///|
/// Get the number of characters in this node
pub fn Node::char_count(self : Node) -> UInt64 {
  self.text_info().chars
}

///|
/// Get the number of line breaks in this node
pub fn Node::line_break_count(self : Node) -> UInt64 {
  self.text_info().line_breaks
}

///|
/// Get the depth of this node in the tree
pub fn Node::depth(self : Node) -> Int {
  match self {
    Leaf(_) => 0
    Internal(children) => {
      let mut max_depth = 0
      for i = 0; i < children.length(); i = i + 1 {
        let child_depth = children.get_node(i).depth()
        if child_depth > max_depth {
          max_depth = child_depth
        }
      }
      max_depth + 1
    }
  }
}

///|
/// Get the number of children (0 for leaf nodes)
pub fn Node::child_count(self : Node) -> Int {
  match self {
    Leaf(_) => 0
    Internal(children) => children.length()
  }
}

///|
/// Get chunk at character index
/// Returns (text_chunk, accumulated_info_before_chunk)
pub fn Node::get_chunk_at_char(
  self : Node,
  char_idx : UInt64,
) -> (String, TextInfo) {
  match self {
    Leaf(text) => (text, TextInfo::new())
    Internal(children) => {
      let (child_idx, acc_info) = children.find_child_at_char(char_idx)
      if child_idx < children.length() {
        let child = children.get_node(child_idx)
        let (chunk, child_acc_info) = child.get_chunk_at_char(
          char_idx - acc_info.chars,
        )
        (chunk, acc_info + child_acc_info)
        // Return last chunk if at end
      } else if children.length() > 0 {
        let last_child = children.get_node(children.length() - 1)
        last_child.get_chunk_at_char(0UL)
      } else {
        ("", TextInfo::new())
      }
    }
  }
}

///|
/// Get chunk at UTF-16 code unit index
pub fn Node::get_chunk_at_utf16_cu(
  self : Node,
  utf16_idx : UInt64,
) -> (String, TextInfo) {
  match self {
    Leaf(text) => (text, TextInfo::new())
    Internal(children) => {
      let (child_idx, acc_info) = children.find_child_at_utf16_cu(utf16_idx)
      if child_idx < children.length() {
        let child = children.get_node(child_idx)
        let (chunk, child_acc_info) = child.get_chunk_at_utf16_cu(
          utf16_idx - acc_info.utf16_cu,
        )
        (chunk, acc_info + child_acc_info)
        // Return last chunk if at end
      } else if children.length() > 0 {
        let last_child = children.get_node(children.length() - 1)
        last_child.get_chunk_at_utf16_cu(0UL)
      } else {
        ("", TextInfo::new())
      }
    }
  }
}

///|
/// Get chunk at line break index
pub fn Node::get_chunk_at_line_break(
  self : Node,
  line_idx : UInt64,
) -> (String, TextInfo) {
  match self {
    Leaf(text) => (text, TextInfo::new())
    Internal(children) => {
      let (child_idx, acc_info) = children.find_child_at_line_break(line_idx)
      if child_idx < children.length() {
        let child = children.get_node(child_idx)
        let (chunk, child_acc_info) = child.get_chunk_at_line_break(
          line_idx - acc_info.line_breaks,
        )
        (chunk, acc_info + child_acc_info)
        // Return last chunk if at end
      } else if children.length() > 0 {
        let last_child = children.get_node(children.length() - 1)
        last_child.get_chunk_at_line_break(0UL)
      } else {
        ("", TextInfo::new())
      }
    }
  }
}

///|
/// Insert text at the given character index
pub fn Node::insert_text(self : Node, char_idx : UInt64, text : String) -> Node {
  match self {
    Leaf(existing_text) =>
      if existing_text.length() == 0 {
        // Empty leaf, just replace with new text
        Leaf(text)
      } else {
        // Convert char index to UTF-16 index for insertion
        let utf16_idx = char_to_utf16_cu_idx(existing_text, char_idx.to_int())
        let before = existing_text.substring(start=0, end=utf16_idx)
        let after = existing_text.substring(
          start=utf16_idx,
          end=existing_text.length(),
        )
        let new_text = before + text + after

        // Check if we need to split this leaf
        if new_text.length() > MAX_BYTES {
          // Split into multiple leaves
          let mid = new_text.length() / 2
          let left_text = new_text.substring(start=0, end=mid)
          let right_text = new_text.substring(start=mid, end=new_text.length())
          let children = NodeChildren::new()
          children.push(TextInfo::from_string(left_text), Leaf(left_text))
          children.push(TextInfo::from_string(right_text), Leaf(right_text))
          Internal(children)
        } else {
          Leaf(new_text)
        }
      }
    Internal(children) => {
      let (child_idx, acc_info) = children.find_child_at_char(char_idx)
      if child_idx < children.length() {
        let child = children.get_node(child_idx)
        let new_child = child.insert_text(char_idx - acc_info.chars, text)

        // Update the child in place
        children.set(child_idx, new_child.text_info(), new_child)
        Internal(children)
        // Insert at the end
      } else if children.length() > 0 {
        let last_idx = children.length() - 1
        let last_child = children.get_node(last_idx)
        let new_last_child = last_child.insert_text(
          last_child.char_count(),
          text,
        )
        children.set(last_idx, new_last_child.text_info(), new_last_child)
        Internal(children)
      } else {
        // Empty internal node, add new leaf
        children.push(TextInfo::from_string(text), Leaf(text))
        Internal(children)
      }
    }
  }
}

///|
/// Split this node at the given character index
/// Returns the right part of the split
pub fn Node::split(self : Node, char_idx : UInt64) -> Node {
  match self {
    Leaf(text) => {
      let utf16_idx = char_to_utf16_cu_idx(text, char_idx.to_int())
      let right_text = text.substring(start=utf16_idx, end=text.length())
      Leaf(right_text)
    }
    Internal(children) => {
      let (child_idx, acc_info) = children.find_child_at_char(char_idx)
      if child_idx < children.length() {
        let child = children.get_node(child_idx)
        let right_child = child.split(char_idx - acc_info.chars)

        // Create new internal node with right part
        let right_children = NodeChildren::new()

        // Add the split right child if it's not empty
        if right_child.char_count() > 0UL {
          right_children.push(right_child.text_info(), right_child)
        }

        // Add all children to the right of the split point
        for i = child_idx + 1; i < children.length(); i = i + 1 {
          let (info, node) = children.get(i)
          right_children.push(info, node)
        }
        Internal(right_children)
      } else {
        // Split point is beyond all children, return empty node
        Internal(NodeChildren::new())
      }
    }
  }
}

///|
/// Append another node to this one
pub fn Node::node_append(self : Node, other : Node) -> Node {
  match (self, other) {
    (Leaf(text1), Leaf(text2)) => {
      let combined = text1 + text2
      if combined.length() <= MAX_BYTES {
        Leaf(combined)
      } else {
        // Need to split into internal node
        let children = NodeChildren::new()
        children.push(TextInfo::from_string(text1), Leaf(text1))
        children.push(TextInfo::from_string(text2), Leaf(text2))
        Internal(children)
      }
    }
    (Leaf(text), Internal(other_children)) => {
      let children = NodeChildren::new()
      children.push(TextInfo::from_string(text), Leaf(text))

      // Add all children from other
      for i = 0; i < other_children.length(); i = i + 1 {
        let (info, node) = other_children.get(i)
        children.push(info, node)
      }
      Internal(children)
    }
    (Internal(self_children), Leaf(text)) => {
      let children = NodeChildren::new()

      // Add all children from self
      for i = 0; i < self_children.length(); i = i + 1 {
        let (info, node) = self_children.get(i)
        children.push(info, node)
      }
      children.push(TextInfo::from_string(text), Leaf(text))
      Internal(children)
    }
    (Internal(self_children), Internal(other_children)) => {
      let children = NodeChildren::new()

      // Add all children from self
      for i = 0; i < self_children.length(); i = i + 1 {
        let (info, node) = self_children.get(i)
        children.push(info, node)
      }

      // Add all children from other
      for i = 0; i < other_children.length(); i = i + 1 {
        let (info, node) = other_children.get(i)
        children.push(info, node)
      }
      Internal(children)
    }
  }
}

///|
/// Convert node to string representation
pub fn Node::node_to_string(self : Node) -> String {
  match self {
    Leaf(text) => text
    Internal(children) => {
      let mut result = ""
      for i = 0; i < children.length(); i = i + 1 {
        result = result + children.get_node(i).node_to_string()
      }
      result
    }
  }
}
