const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var name = try std.ArrayList(u8).initCapacity(b.allocator, 10);
    defer name.deinit(b.allocator);

    try name.appendSlice(b.allocator, "zig-playground");

    const exe = b.addExecutable(.{
        .name = name.items,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    b.step("run", "Run the zig_demo executable").dependOn(&run_cmd.step);
}
