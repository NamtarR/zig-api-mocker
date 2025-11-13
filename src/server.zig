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
        switch (route.method) {
            .get => router.get(route.path, handleRequest, .{}),
            .head => router.head(route.path, handleRequest, .{}),
            .post => router.post(route.path, handleRequest, .{}),
            .put => router.put(route.path, handleRequest, .{}),
            .patch => router.patch(route.path, handleRequest, .{}),
            .delete => router.delete(route.path, handleRequest, .{}),
            .options => router.options(route.path, handleRequest, .{}),
            .connect => router.connect(route.path, handleRequest, .{}),
        }
    }

    try server.listen();
}

fn handleRequest(context: Context, req: *httpz.Request, res: *httpz.Response) !void {
    const method = try stringToMethod(context.allocator, @tagName(req.method));
    const route = findRoute(context.config.routes, req.url.path, method) orelse return;

    for (context.config.headers) |header| {
        res.header(header.key, header.value);
    }

    res.status = route.status;
    res.body = route.response;
}
