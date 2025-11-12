/// Constants for the Rope data structure, based on Ropey implementation
/// These values are optimized for performance and memory usage

///|
/// Maximum number of bytes a leaf node can contain
/// This is larger than Ropey's default because MoonBit uses UTF-16 internally
const MAX_BYTES : Int = 1024
