const std = @import("std");
const Config = @import("config.zig").Config;
const Header = @import("header.zig").Header;
const Route = @import("route.zig").Route;
const Method = @import("method.zig").Method;
const stringToMethod = @import("method.zig").stringToMethod;

const arg_help = "--help";
const arg_port = "--port";
const arg_route = "--route";
const arg_header = "--global-header";

const port_default: u16 = 9876;

const ArgsResult = union(enum) {
    help,
    config: Config,
};

const ArgsError = error{
    PortError,
    RouteError,
    HeaderError,
    UnknownArgumentError,
};

pub fn parseArgs(allocator: std.mem.Allocator) !ArgsResult {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // Skip the first one, as it's the name of the program

    var port: u16 = port_default;
    var routes = try std.ArrayList(Route).initCapacity(allocator, 8);
    var headers = try std.ArrayList(Header).initCapacity(allocator, 8);

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, arg_help)) {
            return .help;
        } else if (std.mem.eql(u8, arg, arg_port)) {
            const port_string = args.next() orelse return error.PortError;

            port = std.fmt.parseInt(u16, port_string, 10) catch return error.PortError;
        } else if (std.mem.eql(u8, arg, arg_route)) {
            const method_string = args.next() orelse return error.RouteError;
            const path_string = args.next() orelse return error.RouteError;
            const response_string = args.next() orelse return error.RouteError;
            const route = parseRoute(allocator, method_string, path_string, response_string) catch return error.RouteError;

            try routes.append(allocator, route);
        } else if (std.mem.eql(u8, arg, arg_header)) {
            const header_string = args.next() orelse return error.HeaderError;
            const header = parseHeader(header_string) catch return error.HeaderError;

            try headers.append(allocator, header);
        } else {
            return error.UnknownArgumentError;
        }
    }

    std.debug.print("routes {d}\n", .{routes.items.len});
    std.debug.print("headers {d}\n", .{headers.items.len});

    const config = Config{
        .port = port,
        .routes = try routes.toOwnedSlice(allocator),
        .headers = try headers.toOwnedSlice(allocator),
    };

    return .{ .config = config };
}

fn parseRoute(
    allocator: std.mem.Allocator,
    method_string: []const u8,
    path_string: []const u8,
    response_string: []const u8,
) !Route {
    const method = try stringToMethod(allocator, method_string);
    const delimeter_index = std.mem.indexOf(u8, response_string, ":") orelse return error.RouteError;
    const status_code = try std.fmt.parseInt(u16, response_string[0..delimeter_index], 10);
    const response = response_string[delimeter_index + 1 ..];

    return Route{
        .method = method,
        .path = path_string,
        .response = response,
        .status = status_code,
    };
}

fn parseHeader(header_string: []const u8) !Header {
    const delimeter_index = std.mem.indexOf(u8, header_string, ":") orelse return error.CommandLineError;
    const key = header_string[0..delimeter_index];
    const value = header_string[delimeter_index + 1 ..];

    return Header{ .key = key, .value = value };
}

test "parse correct route" {
    const allocator = std.testing.allocator;
    const route = try parseRoute(allocator, "GET", "/api/users", "200:{\"test\": \"success\"}");

    try std.testing.expectEqual(Method.get, route.method);
    try std.testing.expectEqualSlices(u8, "/api/users", route.path);
    try std.testing.expectEqualSlices(u8, "{\"test\": \"success\"}", route.response);
    try std.testing.expectEqual(@as(u16, 200), route.status);
}

test "parse incomplete route returns error" {
    const allocator = std.testing.allocator;
    _ = parseRoute(allocator, "/api/users", "200:{\"test\": \"success\"}", "--route") catch return;

    return ArgsError.RouteError;
}

test "parse incorrect route method returns error" {
    const allocator = std.testing.allocator;
    _ = parseRoute(allocator, "wft", "/api/users", "200:{\"test\": \"success\"}") catch return;

    return ArgsError.RouteError;
}

test "parse incorrect route status code returns error" {
    const allocator = std.testing.allocator;
    _ = parseRoute(allocator, "wft", "/api/users", "not-a-status-code:{\"test\": \"success\"}") catch return;

    return ArgsError.RouteError;
}

test "parse missing route status code returns error" {
    const allocator = std.testing.allocator;
    _ = parseRoute(allocator, "wft", "/api/users", "{\"test\": \"success\"}") catch return;

    return ArgsError.RouteError;
}

test "parse correct header" {
    const header = try parseHeader("X-Correct-Header:completely correct header");

    try std.testing.expectEqualSlices(u8, "X-Correct-Header", header.key);
    try std.testing.expectEqualSlices(u8, "completely correct header", header.value);
}

test "parse malformed header" {
    _ = parseHeader("X-Correct-Header completely correct header") catch return;

    return ArgsError.HeaderError;
}
