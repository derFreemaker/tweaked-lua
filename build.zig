const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const build_lua = b.option(bool, "build_lua", "Build lua executable") orelse false;
    const build_luac = b.option(bool, "build_luac", "Build lua executable") orelse false;
    const shared = b.option(bool, "shared", "Build shared library instead of static") orelse false;
    const lua_user_h = b.option(std.Build.LazyPath, "lua_user_h", "Lazy path to user supplied c header file") orelse null;

    const lua_version = std.SemanticVersion{ .major = 5, .minor = 4, .patch = 8 };

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "lua54",
        .linkage = .static,
        .version = lua_version,
        .root_module = lib_mod,
    });

    lib_mod.addIncludePath(b.path("src"));

    const user_header = "user.h";
    const flags = [_][]const u8{
        // Standard version used in Lua Makefile
        "-std=gnu99",

        // Define target-specific macro
        switch (target.result.os.tag) {
            .linux => "-DLUA_USE_LINUX",
            .macos => "-DLUA_USE_MACOSX",
            .windows => "-DLUA_USE_WINDOWS",
            else => "-DLUA_USE_POSIX",
        },

        // Enable api check
        if (optimize == .Debug) "-DLUA_USE_APICHECK" else "",
        
        if (lua_user_h) |_| b.fmt("-DLUA_USER_H=\"{s}\"", .{user_header}) else "",

        "-DLUA_COMPAT_5_3",
    };
    const lib_flags = flags ++ [_][]const u8{
        // Build as DLL for windows if shared
        if (target.result.os.tag == .windows and shared) "-DLUA_BUILD_AS_DLL" else "",
    };
    lib.linkLibC();

    lib_mod.addCSourceFiles(.{
        .language = .c,
        .root = b.path("."),
        .files = &lua_source_files,
        .flags = &lib_flags,
    });

    const install_lib = b.addInstallArtifact(lib, .{});

    const c_headers = b.addTranslateC(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/lua_all.h"),
    });
    c_headers.addIncludePath(lib.getEmittedIncludeTree());
    c_headers.step.dependOn(&install_lib.step);

    _ = b.addModule("headers", .{
        .target = target,
        .optimize = optimize,

        .root_source_file = c_headers.getOutput(),
        .link_libc = c_headers.link_libc,
    });

    const exposed_lib = b.addLibrary(.{
        .name = "lua54",
        .linkage = if (shared) .dynamic else .static,
        .root_module = lib_mod,
    });
    b.installArtifact(exposed_lib);

    exposed_lib.linkLibC();

    exposed_lib.installHeader(b.path("src/lua.h"), "lua.h");
    exposed_lib.installHeader(b.path("src/lualib.h"), "lualib.h");
    exposed_lib.installHeader(b.path("src/lauxlib.h"), "lauxlib.h");
    exposed_lib.installHeader(b.path("src/luaconf.h"), "luaconf.h");

    if (lua_user_h) |user_h| {
        exposed_lib.addIncludePath(user_h.dirname());
        exposed_lib.installHeader(user_h, user_header);
    }

    if (build_lua) {
        const exe_mod = b.createModule(.{
            .target = target,
            .optimize = optimize,
        });

        const exe = b.addExecutable(.{
            .name = "lua",
            .version = lua_version,

            .root_module = exe_mod,
        });
        exe.rdynamic = true;

        exe_mod.addIncludePath(b.path("src"));

        exe_mod.addCSourceFile(.{
            .language = .c,
            .file = b.path("src/lua.c"),
            .flags = &flags,
        });
        exe_mod.linkLibrary(lib);
        exe.step.dependOn(&install_lib.step);

        b.installArtifact(exe);
    }

    if (build_luac) {
        const exe_mod = b.createModule(.{
            .target = target,
            .optimize = optimize,
        });

        const exe = b.addExecutable(.{
            .name = "luac",
            .version = lua_version,

            .root_module = exe_mod,
        });
        exe.rdynamic = true;

        exe_mod.addIncludePath(b.path("src"));

        exe_mod.addCSourceFile(.{
            .language = .c,
            .file = b.path("src/luac.c"),
            .flags = &flags,
        });
        exe_mod.linkLibrary(lib);
        exe.step.dependOn(&install_lib.step);

        b.installArtifact(exe);
    }
}

const lua_source_files = [_][]const u8{
    "src/lapi.c",
    "src/lcode.c",
    "src/ldebug.c",
    "src/ldump.c",
    "src/lfunc.c",
    "src/lgc.c",
    "src/llex.c",
    "src/lmem.c",
    "src/lobject.c",
    "src/lopcodes.c",
    "src/lparser.c",
    "src/lstate.c",
    "src/lstring.c",
    "src/ltable.c",
    "src/ltm.c",
    "src/lundump.c",
    "src/lvm.c",
    "src/lzio.c",
    "src/lauxlib.c",
    "src/lbaselib.c",
    "src/ldblib.c",
    "src/liolib.c",
    "src/lmathlib.c",
    "src/loslib.c",
    "src/ltablib.c",
    "src/lstrlib.c",
    "src/loadlib.c",
    "src/linit.c",
    "src/ldo.c",
    "src/lctype.c",
    "src/lcorolib.c",
    "src/lutf8lib.c",
};
