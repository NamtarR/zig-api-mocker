const std = @import("std");
const httpz = @import("httpz");
const Config = @import("config.zig").Config;

const findRoute = @import("route.zig").findRoute;
const Route = @import("route.zig").Route;

const utils = @import("utils.zig");

pub const Context = struct {
    config: *const Config,
};

pub fn initWithConfig(allocator: std.mem.Allocator, config: *const Config) !void {
    const context = Context{ .config = config };
    var server = try httpz.Server(Context).init(allocator, .{ .port = config.*.port }, context);
    var router = try server.router(.{});

    for (context.config.routes) |route| {
        router.get(route.path, handleRequest, .{});
    }

    try server.listen();
}

fn handleRequest(context: Context, req: *httpz.Request, res: *httpz.Response) !void {
    const route = findRoute(context.config.routes, req.url.path) orelse return;

    res.status = route.status;
    res.body = route.response;
}
