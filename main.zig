const std = @import("std");

pub fn main() !void {
    const path = ".";
    const needle = "tagit.c";
    try printDirContents(path, needle);
}

pub fn printDirContents(path: []const u8, needle: []const u8) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var dirIterator = dir.iterate();
    while (try dirIterator.next()) |dirContent| {
        if (dirContent.kind == std.fs.File.Kind.directory) {
            // std.debug.print("{s}/{s}\n", .{ path, dirContent.name });
            var buf: [1024]u8 = undefined;
            const foo = try std.fmt.bufPrint(&buf, "{s}/{s}", .{ path, dirContent.name });
            try printDirContents(foo, needle);
        } else if (dirContent.kind == std.fs.File.Kind.file) {
            if (std.mem.eql(u8, dirContent.name, needle)) {
                std.debug.print("{s}/{s}\n", .{ path, dirContent.name });
            }
        }
    }
}
