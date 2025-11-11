const std = @import("std");
const Route = @import("route.zig").Route;

pub const Config = struct {
    port: u16 = 9876,
    routes: []const Route,
};

pub const ConfigError = error{
    ResponseFilesError,
    CommandLineError,
};

pub fn readConfig(allocator: std.mem.Allocator) !Config {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    var port: u16 = 3000;
    var routes = try std.ArrayList(Route).initCapacity(allocator, 8);

    _ = args.skip();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--route")) {
            const route_path = args.next() orelse return ConfigError.CommandLineError;
            const route_response = args.next() orelse return ConfigError.CommandLineError;
            const route = try parseRoute(route_path, route_response);

            try routes.append(allocator, route);
        } else if (std.mem.eql(u8, arg, "--port")) {
            const port_string = args.next() orelse return ConfigError.CommandLineError;

            port = try parsePort(port_string);
        } else {}
    }

    return Config{
        .port = port,
        .routes = routes.items,
    };
}

fn parseRoute(path: []const u8, response: []const u8) !Route {
    const delimiter_index = std.mem.indexOf(u8, response, ":") orelse return ConfigError.CommandLineError;
    const response_status_code = response[0..delimiter_index];
    const response_data = response[delimiter_index + 1 ..];

    return Route{
        .path = path,
        .status = try std.fmt.parseInt(u16, response_status_code, 10),
        .response = response_data,
    };
}

fn parsePort(port_string: []const u8) !u16 {
    return try std.fmt.parseInt(u16, port_string, 10);
}
