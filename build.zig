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
        .name = "lua5.4",
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

        // Build as DLL for windows if shared
        if (target.result.os.tag == .windows and shared) "-DLUA_BUILD_AS_DLL" else "",

        if (lua_user_h) |_| b.fmt("-DLUA_USER_H=\"{s}\"", .{user_header}) else "",
    };

    lib_mod.addCSourceFiles(.{
        .root = b.path("."),
        .files = &lua_source_files,
        .flags = &flags,
    });

    lib.linkLibC();

    lib.installHeader(b.path("src/lua.h"), "lua.h");
    lib.installHeader(b.path("src/lualib.h"), "lualib.h");
    lib.installHeader(b.path("src/lauxlib.h"), "lauxlib.h");
    lib.installHeader(b.path("src/luaconf.h"), "luaconf.h");

    if (lua_user_h) |user_h| {
        lib.addIncludePath(user_h.dirname());
        lib.installHeader(user_h, user_header);
    }
    
    b.installArtifact(lib);
    
    _ = b.addModule("includes", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/includes.zig"),
    });
    
    if (shared) {
        const shared_lib = b.addLibrary(.{
            .name = "lua5.4",
            .linkage = .dynamic,
            .root_module = lib_mod,
        });
        
        b.installArtifact(shared_lib);
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

        exe_mod.addIncludePath(b.path("src"));

        exe_mod.addCSourceFile(.{
            .file = b.path("src/lua.c"),
            .flags = &flags,
        });
        exe_mod.linkLibrary(lib);

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

        exe_mod.addIncludePath(b.path("src"));

        exe_mod.addCSourceFile(.{
            .file = b.path("src/luac.c"),
            .flags = &flags,
        });
        exe_mod.linkLibrary(lib);

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
