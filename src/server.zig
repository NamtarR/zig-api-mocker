const std = @import("std");
const httpz = @import("httpz");
const Config = @import("config.zig").Config;
const Route = @import("route.zig").Route;
const findRoute = @import("route.zig").findRoute;
const stringToMethod = @import("method.zig").stringToMethod;

pub const Context = struct {
    config: *const Config,
    allocator: std.mem.Allocator,
};

pub fn initWithConfig(allocator: std.mem.Allocator, config: *const Config) !void {
    const context = Context{ .config = config, .allocator = allocator };
    var server = try httpz.Server(Context).init(allocator, .{ .port = config.port }, context);
    var router = try server.router(.{});

    for (context.config.routes) |route| {
        router.get(route.path, handleRequest, .{});
    }

    try server.listen();
}

fn handleRequest(context: Context, req: *httpz.Request, res: *httpz.Response) !void {
    const method = try stringToMethod(context.allocator, @tagName(req.method));
    const route = findRoute(context.config.routes, req.url.path, method) orelse return;

    res.status = route.status;
    res.body = route.response;
}
