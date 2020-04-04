const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    create_exe(b, "server", "server.zig");
    create_exe(b, "client", "client.zig");
}

fn create_exe(b: *Builder, name: []const u8, entry_point: []const u8) void {
    const mode = b.standardReleaseOptions();

    var exe = b.addExecutable(name, entry_point);
    exe.addCSourceFile("include/dyad/dyad.c", &[_][]const u8{"-std=c99"});
    exe.setBuildMode(mode);
    exe.addIncludeDir("include");
    exe.linkSystemLibrary("c");
    exe.install();
}
