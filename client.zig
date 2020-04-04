const std = @import("std");

const c = @cImport({
    @cInclude("dyad/dyad.h");
});

const Callback = ?fn (event: [*c]c.dyad_Event) callconv(.C) void;

pub fn main() void {
    std.debug.warn("Hello Client\n", .{});

    c.dyad_init();
    c.dyad_setUpdateTimeout(0.01);
    var stream: *c.dyad_Stream = c.dyad_newStream() orelse @panic("error");

    c.dyad_addListener(stream, c.DYAD_EVENT_CONNECT, @ptrCast(Callback, on_connect), null);
    c.dyad_addListener(stream, c.DYAD_EVENT_DATA, @ptrCast(Callback, on_data), null);
    _ = c.dyad_connect(stream, "127.0.0.1", 8123);
    defer c.dyad_shutdown();

    while (true) {
        c.dyad_update();
    }
}

fn on_connect(event: *c.dyad_Event) void {
    var i: usize = 0;
    while (i < 10000 and event.msg[i] != 0) : (i += 1) {}
    std.debug.warn("on_connect: {}\n", .{event.msg[0..i]});
    c.dyad_writef(event.stream, "Echo client\n");
}

fn on_data(event: *c.dyad_Event) void {
    std.debug.warn("on_data: {}\n", .{event.data[0..@intCast(usize, event.size)]});
}
