const std = @import("std");
const Method = @import("method.zig").Method;

pub const Response = union(enum) {
    static: []const u8,
    file: []const u8,
};

pub const Route = struct { method: Method, path: []const u8, status: u16 = 200, response: Response };

pub fn findRoute(routes: []const Route, path: []const u8, method: Method) ?Route {
    for (routes) |route| {
        if (std.mem.eql(u8, route.path, path) and route.method == method) {
            return route;
        }
    }

    return null;
}
