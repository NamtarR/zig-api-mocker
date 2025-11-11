const std = @import("std");
const httpz = @import("httpz");
const config_module = @import("config.zig");
const server_module = @import("server.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const config = config_module.readConfig(allocator) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };

    const server = try server_module.initWithConfig(allocator, &config);

    _ = server;

    for (config.routes) |route| {
        std.debug.print("Route {s} will respond with {d} and {s}\n", .{ route.path, route.status, route.response });
    }

    std.debug.print("The server will listen on {d}\n", .{config.port});
}
