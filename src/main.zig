const std = @import("std");
const httpz = @import("httpz");
const config_module = @import("config.zig");
const Config = config_module.Config;
const server_module = @import("server.zig");
const parseArgs = @import("args.zig").parseArgs;
const VERSION = @import("version.zig").VERSION;
const strings = @import("strings.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const argsResult = try parseArgs(allocator);

    switch (argsResult) {
        .help => {
            try printHelp(allocator);
        },
        .version => {
            try printVersion(allocator);
        },
        .config => {
            try startServer(allocator, &argsResult.config);
        },
    }
}

fn startServer(allocator: std.mem.Allocator, config: *const Config) !void {
    _ = try server_module.initWithConfig(allocator, config);
}

fn printHelp(allocator: std.mem.Allocator) !void {
    const help = try std.fmt.allocPrint(allocator, strings.CLI_HELP, .{VERSION});
    _ = try std.fs.File.stdout().write(help);
}

fn printVersion(allocator: std.mem.Allocator) !void {
    const help = try std.fmt.allocPrint(allocator, strings.CLI_VERSION, .{VERSION});
    _ = try std.fs.File.stdout().write(help);
}
