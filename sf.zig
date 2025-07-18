const std = @import("std");
const builtin = @import("builtin");

pub fn main() !void {
    const alloc: std.mem.Allocator = init: {
        var buffer: [1024]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        break :init fba.allocator();
    };
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    const len = args.len;
    var path: []const u8 = ".";
    var filename: [:0]u8 = undefined;
    switch (len) {
        2 => {
            filename = args[1];
        },
        3 => {
            var buf: [1024]u8 = undefined;
            const inputPath = try std.fmt.bufPrint(&buf, "{s}", .{args[1]});
            const trimedPath = std.mem.trimRight(u8, inputPath, "/");
            path = trimedPath;
            filename = args[2];
        },
        else => {
            std.debug.print("Usage: sf [dir] <filename>\n", .{});
            std.process.exit(1);
        },
    }

    // std.debug.print("PATH GIVEN: {s}\n", .{path});

    const stdout = std.io.getStdOut().writer();
    printDirContents(path, filename, stdout) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("sf: Couldn't find directory: {s}\n", .{path});
            std.process.exit(1);
        },

        else => |leftover_err| return leftover_err,
    };
}

pub fn printDirContents(path: []const u8, needle: []const u8, stdout: std.fs.File.Writer) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var dirIterator = dir.iterate();
    while (try dirIterator.next()) |dirContent| {
        if (dirContent.kind == std.fs.File.Kind.directory) {
            // std.debug.print("{s}/{s}\n", .{ path, dirContent.name });
            var buf: [1024]u8 = undefined;
            const format: []const u8 = if (builtin.target.os.tag == .windows) "{s}\\{s}" else "{s}/{s}";
            const newPath = try std.fmt.bufPrint(&buf, format, .{ path, dirContent.name });
            try printDirContents(newPath, needle, stdout);
        } else {
            if (std.mem.eql(u8, dirContent.name, needle)) {
                // std.debug.print("{s}/{s}\n", .{ path, dirContent.name });
                const format: []const u8 = if (builtin.target.os.tag == .windows) "{s}\\{s}\n" else "{s}/{s}\n";
                try stdout.print(format, .{ path, dirContent.name });
            }
        }
    }
}
