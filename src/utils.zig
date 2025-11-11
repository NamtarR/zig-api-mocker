pub fn find(comptime T: type, items: []T, predicate: fn (T) bool) ?T {
    for (items) |item| {
        if (predicate(item)) {
            return item;
        }
    }

    return null;
}
