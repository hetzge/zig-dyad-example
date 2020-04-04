const std = @import("std");

const c = @cImport({
    @cInclude("dyad/dyad.h");
});

const Callback = ?fn (event: [*c]c.dyad_Event) callconv(.C) void;

pub fn main() void {
    std.debug.warn("Hello Server\n", .{});

    c.dyad_init();
    c.dyad_setUpdateTimeout(0.01);
    var stream: *c.dyad_Stream = c.dyad_newStream() orelse @panic("error");

    c.dyad_addListener(stream, c.DYAD_EVENT_ACCEPT, @ptrCast(Callback, on_accept), null);
    _ = c.dyad_listenEx(stream, "127.0.0.1", 8123, 10);
    defer c.dyad_shutdown();

    while (true) {
        c.dyad_update();
    }
}

fn on_accept(event: *c.dyad_Event) void {
    std.debug.warn("on_accept\n", .{});
    c.dyad_addListener(event.remote, c.DYAD_EVENT_DATA, @ptrCast(Callback, on_data), null);
    c.dyad_writef(event.remote, "Echo server\n");
}

fn on_data(event: *c.dyad_Event) void {
    std.debug.warn("on_data: {}\n", .{event.data[0..@intCast(usize, event.size)]});
    c.dyad_write(event.stream, event.data, event.size);
}
