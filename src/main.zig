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
            std.debug.print("Config {d}\n", .{argsResult.config.port});
            try startServer(allocator, &argsResult.config);
        },
    }
}

fn startServer(allocator: std.mem.Allocator, config: *const Config) !void {
    const server = try server_module.initWithConfig(allocator, config);

    _ = server;
}
