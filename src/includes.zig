pub const c = @cImport(.{
    @cInclude("lua.h"),
    @cInclude("lualib.h"),
    @cInclude("luaxlib.h"),
    @cInclude("luaconf.h"),
});