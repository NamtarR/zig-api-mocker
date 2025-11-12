const std = @import("std");
const Route = @import("route.zig").Route;
const Header = @import("header.zig").Header;

pub const Config = struct {
    port: u16 = 9876,
    routes: []const Route = &[_]Route{},
    headers: []const Header = &[_]Header{},
};
