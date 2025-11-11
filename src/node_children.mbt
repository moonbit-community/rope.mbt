///|
/// Container for child nodes in internal nodes
/// Each child is stored with its accumulated text information
pub struct NodeChildren {
  mut children : Array[(TextInfo, Node)]
}

///|
/// Create a new empty NodeChildren container
pub fn NodeChildren::new() -> NodeChildren {
  { children: [] }
}

///|
/// Create NodeChildren with initial capacity
pub fn NodeChildren::with_capacity(capacity : Int) -> NodeChildren {
  { children: Array::make(capacity, (TextInfo::new(), Node::new_empty())) }
}

///|
/// Get the number of children
pub fn NodeChildren::length(self : NodeChildren) -> Int {
  self.children.length()
}

///|
/// Check if container is empty
pub fn NodeChildren::children_is_empty(self : NodeChildren) -> Bool {
  self.children.length() == 0
}

///|
/// Add a child node with its text info
pub fn NodeChildren::push(
  self : NodeChildren,
  info : TextInfo,
  node : Node,
) -> Unit {
  self.children.push((info, node))
}

///|
/// Get child at index
pub fn NodeChildren::get(self : NodeChildren, index : Int) -> (TextInfo, Node) {
  self.children[index]
}

///|
/// Get text info at index
pub fn NodeChildren::get_info(self : NodeChildren, index : Int) -> TextInfo {
  let (info, _) = self.children[index]
  info
}

///|
/// Get node at index
pub fn NodeChildren::get_node(self : NodeChildren, index : Int) -> Node {
  let (_, node) = self.children[index]
  node
}

///|
/// Set child at index
pub fn NodeChildren::set(
  self : NodeChildren,
  index : Int,
  info : TextInfo,
  node : Node,
) -> Unit {
  self.children[index] = (info, node)
}

///|
/// Insert child at index
pub fn NodeChildren::children_insert(
  self : NodeChildren,
  index : Int,
  info : TextInfo,
  node : Node,
) -> Unit {
  // Create new array with one more element
  let new_children = Array::make(
    self.children.length() + 1,
    (TextInfo::new(), Node::new_empty()),
  )

  // Copy elements before insertion point
  for i = 0; i < index; i = i + 1 {
    new_children[i] = self.children[i]
  }

  // Insert new element
  new_children[index] = (info, node)

  // Copy elements after insertion point
  for i = index; i < self.children.length(); i = i + 1 {
    new_children[i + 1] = self.children[i]
  }
  self.children = new_children
}

///|
/// Remove and return child at index
pub fn NodeChildren::children_remove(
  self : NodeChildren,
  index : Int,
) -> (TextInfo, Node) {
  let result = self.children[index]

  // Create new array with one less element
  let new_children = Array::make(
    self.children.length() - 1,
    (TextInfo::new(), Node::new_empty()),
  )

  // Copy elements before removal point
  for i = 0; i < index; i = i + 1 {
    new_children[i] = self.children[i]
  }

  // Copy elements after removal point
  for i = index + 1; i < self.children.length(); i = i + 1 {
    new_children[i - 1] = self.children[i]
  }
  self.children = new_children
  result
}

///|
/// Split children at index, returning the right part
pub fn NodeChildren::split_off(self : NodeChildren, at : Int) -> NodeChildren {
  let right_len = self.children.length() - at
  let right_children = Array::make(
    right_len,
    (TextInfo::new(), Node::new_empty()),
  )

  // Copy right part
  for i = 0; i < right_len; i = i + 1 {
    right_children[i] = self.children[at + i]
  }

  // Truncate left part
  let left_children = Array::make(at, (TextInfo::new(), Node::new_empty()))
  for i = 0; i < at; i = i + 1 {
    left_children[i] = self.children[i]
  }
  self.children = left_children
  { children: right_children }
}

///|
/// Combine all text info from children
pub fn NodeChildren::total_info(self : NodeChildren) -> TextInfo {
  let mut result = TextInfo::new()
  for i = 0; i < self.children.length(); i = i + 1 {
    let (info, _) = self.children[i]
    result = result + info
  }
  result
}

///|
/// Find the child that contains the given character index
/// Returns (child_index, accumulated_info_before_child)
pub fn NodeChildren::find_child_at_char(
  self : NodeChildren,
  char_idx : UInt64,
) -> (Int, TextInfo) {
  let mut acc_info = TextInfo::new()
  for i = 0; i < self.children.length(); i = i + 1 {
    let (info, _) = self.children[i]
    if char_idx < acc_info.chars + info.chars {
      return (i, acc_info)
    }
    acc_info = acc_info + info
  }

  // Return last child if index is at the end
  if self.children.length() > 0 {
    let last_idx = self.children.length() - 1
    let total = self.total_info()
    let (last_info, _) = self.children[last_idx]
    (last_idx, total - last_info)
  } else {
    (0, TextInfo::new())
  }
}

///|
/// Find the child that contains the given UTF-16 code unit index
pub fn NodeChildren::find_child_at_utf16_cu(
  self : NodeChildren,
  utf16_idx : UInt64,
) -> (Int, TextInfo) {
  let mut acc_info = TextInfo::new()
  for i = 0; i < self.children.length(); i = i + 1 {
    let (info, _) = self.children[i]
    if utf16_idx < acc_info.utf16_cu + info.utf16_cu {
      return (i, acc_info)
    }
    acc_info = acc_info + info
  }

  // Return last child if index is at the end
  if self.children.length() > 0 {
    let last_idx = self.children.length() - 1
    let total = self.total_info()
    let (last_info, _) = self.children[last_idx]
    (last_idx, total - last_info)
  } else {
    (0, TextInfo::new())
  }
}

///|
/// Find the child that contains the given line break index
pub fn NodeChildren::find_child_at_line_break(
  self : NodeChildren,
  line_idx : UInt64,
) -> (Int, TextInfo) {
  let mut acc_info = TextInfo::new()
  for i = 0; i < self.children.length(); i = i + 1 {
    let (info, _) = self.children[i]
    if line_idx <= acc_info.line_breaks + info.line_breaks {
      return (i, acc_info)
    }
    acc_info = acc_info + info
  }

  // Return last child if index is at the end
  if self.children.length() > 0 {
    let last_idx = self.children.length() - 1
    let total = self.total_info()
    let (last_info, _) = self.children[last_idx]
    (last_idx, total - last_info)
  } else {
    (0, TextInfo::new())
  }
}
