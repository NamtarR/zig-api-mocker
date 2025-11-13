const std = @import("std");

pub const Method = enum {
    get,
    head,
    post,
    put,
    patch,
    delete,
    options,
    connect,
};

pub fn stringToMethod(allocator: std.mem.Allocator, string: []const u8) !Method {
    const string_lowercase = try std.ascii.allocLowerString(allocator, string);
    defer allocator.free(string_lowercase);

    return std.meta.stringToEnum(Method, string_lowercase) orelse return error.InvalidCharacter;
}
