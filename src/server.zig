const std = @import("std");
const httpz = @import("httpz");
const Config = @import("config.zig").Config;
const Route = @import("route.zig").Route;
const findRoute = @import("route.zig").findRoute;
const stringToMethod = @import("method.zig").stringToMethod;
const VERSION = @import("version.zig").VERSION;

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

    try addStaticHeaders(&context, res);

    res.status = route.status;
    res.body = route.response;
}

fn addStaticHeaders(context: *const Context, res: *httpz.Response) !void {
    const date = try std.fmt.allocPrint(context.allocator, "{d}", .{std.time.timestamp()});
    const server = try std.fmt.allocPrint(context.allocator, "zig-api-mocker/{s}", .{VERSION});

    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Header", "*");
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS");
    res.header("Content-Type", "application/json");
    res.header("Date", date);
    res.header("Server", server);

    //Content-Length is added automatically when setting the response data
}
