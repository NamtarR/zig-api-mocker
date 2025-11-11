const std = @import("std");

pub const Route = struct {
    path: []const u8,
    status: u16 = 200,
    response: []const u8,
};

pub fn findRoute(routes: []const Route, path: []const u8) ?Route {
    for (routes) |route| {
        if (std.mem.eql(u8, route.path, path)) {
            return route;
        }
    }

    return null;
}
