const std = @import("std");
const options = @import("build_options");

pub const VERSION = std.mem.trim(u8, options.version, "\n\r");

pub const TIME = "{d:0>2}:{d:0>2}:{d:0>2}";
pub const SERVER = "zig-api-mocker/{s}";

pub const LOG_CONFIG = "Listening on port {d} with {d} registered routes and {d} headers\n\n";
pub const LOG_REQUEST = "[{s}] {f} {s} {s} -> {d} ({d}ms)\n";

pub const CLI_HELP =
    \\zig-api-mocker/{s}
    \\Simple mock API server for development.
    \\
    \\Usage: zig-api-mocker [options]
    \\
    \\Options:
    \\    --help      Show this help
    \\    --version   Show version
    \\    --port <num>
    \\              Port (default: 3000)
    \\    --config <file>
    \\              Load configuration from JSON-file
    \\    --route <method> <path> '<status>:<body>'
    \\              <body> can be a JSON string
    \\              or a file path specified with a preceding '@'
    \\    --global-header '<key>: <value>'
    \\
;
pub const CLI_VERSION = "zig-api-mocker {s}\n";
