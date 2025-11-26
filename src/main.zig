const std = @import("std");
const httpz = @import("httpz");
const config_module = @import("config.zig");
const Config = config_module.Config;
const server_module = @import("server.zig");
const parseArgs = @import("args.zig").parseArgs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const argsResult = try parseArgs(allocator);

    switch (argsResult) {
        .help => {},
        .config => {
            try startServer(allocator, &argsResult.config);
        },
    }
}

fn startServer(allocator: std.mem.Allocator, config: *const Config) !void {
    _ = try server_module.initWithConfig(allocator, config);
}
