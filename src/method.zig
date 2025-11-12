const std = @import("std");

pub const Method = enum {
    get,
    post,
    put,
    delete,
};

pub fn stringToMethod(allocator: std.mem.Allocator, string: []const u8) !Method {
    const string_lowercase = try std.ascii.allocLowerString(allocator, string);
    defer allocator.free(string_lowercase);

    return std.meta.stringToEnum(Method, string_lowercase) orelse return error.InvalidCharacter;
}
