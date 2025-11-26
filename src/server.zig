const std = @import("std");
const httpz = @import("httpz");
const Config = @import("config.zig").Config;
const Route = @import("route.zig").Route;
const findRoute = @import("route.zig").findRoute;
const stringToMethod = @import("method.zig").stringToMethod;
const strings = @import("strings.zig");

pub const Context = struct {
    config: *const Config,
    allocator: std.mem.Allocator,
    output: std.fs.File = std.fs.File.stdout(),

    pub fn deinit(self: *Context) !void {
        self.allocator.free(self.buffer);
    }

    pub fn dispatch(self: *Context, action: httpz.Action(*Context), req: *httpz.Request, res: *httpz.Response) !void {
        const start_time = std.time.microTimestamp();

        try action(self, req, res);

        const end_time = std.time.microTimestamp();

        try self.logRequest(req, res, start_time, end_time);
    }

    fn logRequest(self: *Context, req: *httpz.Request, res: *httpz.Response, start_time: i64, end_time: i64) !void {
        const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000.0;
        const timestamp = std.time.epoch.EpochSeconds{ .secs = @intCast(@divTrunc(start_time, 1_000_000)) };
        const time = try std.fmt.allocPrint(self.allocator, strings.TIME, .{
            timestamp.getDaySeconds().getHoursIntoDay(),
            timestamp.getDaySeconds().getMinutesIntoHour(),
            timestamp.getDaySeconds().getSecondsIntoMinute(),
        });

        const log_line = try std.fmt.allocPrint(self.allocator, strings.LOG_REQUEST, .{
            time,
            req.address.in,
            @tagName(req.method),
            req.url.path,
            res.status,
            duration,
        });

        _ = try self.output.write(log_line);
    }

    fn logConfig(self: *Context) !void {
        const log_line = try std.fmt.allocPrint(self.allocator, strings.LOG_CONFIG, .{
            self.config.port,
            self.config.routes.len,
            self.config.headers.len,
        });

        _ = try self.output.write(log_line);
    }
};

pub fn initWithConfig(allocator: std.mem.Allocator, config: *const Config) !void {
    var context = Context{ .config = config, .allocator = allocator };
    var server = try httpz.Server(*Context).init(allocator, .{ .port = config.port }, &context);
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

    try context.logConfig();

    try server.listen();
}

fn handleRequest(context: *Context, req: *httpz.Request, res: *httpz.Response) !void {
    const method = try stringToMethod(context.allocator, @tagName(req.method));
    const route = findRoute(context.config.routes, req.url.path, method) orelse return;

    for (context.config.headers) |header| {
        res.header(header.key, header.value);
    }

    try addStaticHeaders(context, res);

    switch (route.response) {
        .static => res.body = route.response.static,
        .file => res.body = try readResponseFile(context, route.response.file),
    }

    res.status = route.status;
}

fn addStaticHeaders(context: *Context, res: *httpz.Response) !void {
    const date = try std.fmt.allocPrint(context.allocator, "{d}", .{std.time.timestamp()});
    const server = try std.fmt.allocPrint(context.allocator, strings.SERVER, .{strings.VERSION});

    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Header", "*");
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS");
    res.header("Content-Type", "application/json");
    res.header("Date", date);
    res.header("Server", server);

    //Content-Length is added automatically when setting the response data
}

fn readResponseFile(context: *Context, file: []const u8) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(context.allocator, file, 4096);
}
