cmake_minimum_required(VERSION 4.0)
project(lua C)

set(CMAKE_C_STANDARD 99)

set(USER_HEADER "user.h")

set(FLAGS
        -std=gnu99
)

# OS-specific macros
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    list(APPEND FLAGS -DLUA_USE_LINUX)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    list(APPEND FLAGS -DLUA_USE_MACOSX)
elseif(WIN32)
    list(APPEND FLAGS -DLUA_USE_WINDOWS)
else()
    list(APPEND FLAGS -DLUA_USE_POSIX)
endif()

# Enable API check for Debug builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND FLAGS -DLUA_USE_APICHECK)
endif()

# Build as DLL for Windows if shared
if(WIN32 AND BUILD_SHARED_LIBS)
    list(APPEND FLAGS -DLUA_BUILD_AS_DLL)
endif()

# Optional user header
if(LUA_USER_H)
    list(APPEND FLAGS -DLUA_USER_H=\"${USER_HEADER}\")
endif()

add_compile_options(${FLAGS})

set(SOURCES
        src/lapi.c
        src/lapi.h
        src/lauxlib.c
        src/lauxlib.h
        src/lbaselib.c
        src/lcode.c
        src/lcode.h
        src/lcorolib.c
        src/lctype.c
        src/lctype.h
        src/ldblib.c
        src/ldebug.c
        src/ldebug.h
        src/ldo.c
        src/ldo.h
        src/ldump.c
        src/lfunc.c
        src/lfunc.h
        src/lgc.c
        src/lgc.h
        src/linit.c
        src/liolib.c
        src/ljumptab.h
        src/llex.c
        src/llex.h
        src/llimits.h
        src/lmathlib.c
        src/lmem.c
        src/lmem.h
        src/loadlib.c
        src/lobject.c
        src/lobject.h
        src/lopcodes.c
        src/lopcodes.h
        src/lopnames.h
        src/loslib.c
        src/lparser.c
        src/lparser.h
        src/lprefix.h
        src/lstate.c
        src/lstate.h
        src/lstring.c
        src/lstring.h
        src/lstrlib.c
        src/ltable.c
        src/ltable.h
        src/ltablib.c
        src/ltm.c
        src/ltm.h
        src/lua.h
        src/luaconf.h
        src/lualib.h
        src/lundump.c
        src/lundump.h
        src/lutf8lib.c
        src/lvm.c
        src/lvm.h
        src/lzio.c
        src/lzio.h
)

set(LUA_EXE_SOURCES
    src/lua.c
)

set(LUAC_EXE_SOURCES
        src/lua.c
)

add_library(liblua STATIC ${SOURCES})
target_link_libraries(liblua m)
set_target_properties(liblua PROPERTIES OUTPUT_NAME "lua5.4")

add_library(lua_shared SHARED ${SOURCES})
target_link_libraries(lua_shared m)
set_target_properties(lua_shared PROPERTIES OUTPUT_NAME "lua5.4")

add_executable(lua ${LUA_EXE_SOURCES})
target_link_libraries(lua liblua)

add_executable(luac ${LUAC_EXE_SOURCES})
target_link_libraries(luac liblua)
