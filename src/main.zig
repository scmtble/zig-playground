const std = @import("std");
const Io = std.Io;
const http = std.http;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const port = 8080;
    const ip = "0.0.0.0";

    const address = try Io.net.IpAddress.parse(ip, port);
    var server = try address.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    std.log.info("Server running at http://{s}:{d}", .{ ip, port });

    while (true) {
        var future = io.async(std.Io.net.Server.accept, .{ &server, io });
        const stream: std.Io.net.Stream = try future.await(io);
        // [TODO] Handle errors properly
        _ = io.concurrent(handleConnection, .{ stream, io }) catch |err| {
            stream.close(io);
            std.log.err("Failed to handle connection: {}", .{err});
            continue;
        };
    }
}

pub fn handleConnection(stream: std.Io.net.Stream, io: Io) !void {
    defer stream.close(io);

    var reader_buffer: [4096]u8 = undefined;
    var writer_buffer: [4096]u8 = undefined;

    var reader = stream.reader(io, &reader_buffer);
    var writer = stream.writer(io, &writer_buffer);

    var http_srv = http.Server.init(&reader.interface, &writer.interface);

    while (true) {
        var request = http_srv.receiveHead() catch |err| {
            if (err == error.HttpConnectionClosing) break; // client closed
            std.log.err("Failed to receive request: {}", .{err});
            break;
        };

        switch (request.head.method) {
            .GET => {
                request.respond("HELLO WORLD!\n", .{
                    .status = .ok,
                    .extra_headers = &[_]http.Header{
                        .{ .name = "Content-Type", .value = "text/plain" },
                    },
                }) catch |err| {
                    std.log.err("Failed to respond: {}", .{err});
                };
            },
            else => {
                request.respond("Method not allowed", .{
                    .status = .method_not_allowed,
                }) catch {};
            },
        }
    }
}
