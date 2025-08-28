/// Constants for the Rope data structure, based on Ropey implementation
/// These values are optimized for performance and memory usage

///|
/// Maximum number of bytes a leaf node can contain
/// This is larger than Ropey's default because MoonBit uses UTF-16 internally
pub let max_bytes : Int = 1024

///|
/// Minimum number of bytes a leaf node should contain (except for the root)
pub let min_bytes : Int = 512

///|
/// Maximum number of children an internal node can have
pub let max_children : Int = 16

///|
/// Minimum number of children an internal node should have (except for the root)  
pub let min_children : Int = 8

///|
/// Buffer size for various operations
pub let buffer_size : Int = max_bytes * 2
