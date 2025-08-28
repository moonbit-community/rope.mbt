/// Constants for the Rope data structure, based on Ropey implementation
/// These values are optimized for performance and memory usage

///|
/// Maximum number of bytes a leaf node can contain
/// This is larger than Ropey's default because MoonBit uses UTF-16 internally
const MAX_BYTES : Int = 1024

///|
/// Minimum number of bytes a leaf node should contain (except for the root)
const MIN_BYTES : Int = 512

///|
/// Maximum number of children an internal node can have
const MAX_CHILDREN : Int = 16

///|
/// Minimum number of children an internal node should have (except for the root)  
const MIN_CHILDREN : Int = 8

///|
/// Buffer size for various operations
const BUFFER_SIZE : Int = MAX_BYTES * 2
