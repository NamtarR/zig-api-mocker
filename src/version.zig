const std = @import("std");
const options = @import("build_options");

pub const VERSION = std.mem.trim(u8, options.version, "\n\r");
