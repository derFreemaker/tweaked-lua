# CMakeLists.txt for src directory
# Equivalent to src/Makefile

# Compiler settings
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Basic compiler flags (equivalent to CFLAGS)
set(LUA_CFLAGS "-O2 -Wall -Wextra -DLUA_COMPAT_5_3")

# Platform-specific system flags and libraries
set(LUA_SYSCFLAGS "")
set(LUA_SYSLDFLAGS "")
set(LUA_SYSLIBS "")

# User-customizable flags
set(LUA_MYCFLAGS "" CACHE STRING "User-defined C flags")
set(LUA_MYLDFLAGS "" CACHE STRING "User-defined linker flags")
set(LUA_MYLIBS "" CACHE STRING "User-defined libraries")

# Special flags for compiler modules
set(LUA_CMCFLAGS "" CACHE STRING "Special flags for compiler modules")

# Platform-specific configurations
if(LUA_PLATFORM STREQUAL "linux" OR LUA_PLATFORM STREQUAL "linux-noreadline")
    set(LUA_SYSCFLAGS "-DLUA_USE_LINUX")
    set(LUA_SYSLIBS "-Wl,-E -ldl")
elseif(LUA_PLATFORM STREQUAL "linux-readline")
    set(LUA_SYSCFLAGS "-DLUA_USE_LINUX -DLUA_USE_READLINE")
    set(LUA_SYSLIBS "-Wl,-E -ldl -lreadline")
elseif(LUA_PLATFORM STREQUAL "freebsd")
    set(LUA_SYSCFLAGS "-DLUA_USE_LINUX -DLUA_USE_READLINE -I/usr/include/edit")
    set(LUA_SYSLIBS "-Wl,-E -ledit")
elseif(LUA_PLATFORM STREQUAL "macosx")
    set(LUA_SYSCFLAGS "-DLUA_USE_MACOSX -DLUA_USE_READLINE")
    set(LUA_SYSLIBS "-lreadline")
elseif(LUA_PLATFORM STREQUAL "mingw")
    set(LUA_SYSCFLAGS "-DLUA_BUILD_AS_DLL")
    set(LUA_SYSLDFLAGS "-s")
    set(LUA_SYSLIBS "")
elseif(LUA_PLATFORM STREQUAL "posix")
    set(LUA_SYSCFLAGS "-DLUA_USE_POSIX")
elseif(LUA_PLATFORM STREQUAL "solaris")
    set(LUA_SYSCFLAGS "-DLUA_USE_POSIX -DLUA_USE_DLOPEN -D_REENTRANT")
    set(LUA_SYSLIBS "-ldl")
elseif(LUA_PLATFORM STREQUAL "aix")
    set(LUA_SYSCFLAGS "-DLUA_USE_POSIX -DLUA_USE_DLOPEN")
    set(LUA_SYSLIBS "-ldl")
    set(LUA_SYSLDFLAGS "-brtl -bexpall")
elseif(LUA_PLATFORM STREQUAL "bsd")
    set(LUA_SYSCFLAGS "-DLUA_USE_POSIX -DLUA_USE_DLOPEN")
    set(LUA_SYSLIBS "-Wl,-E")
elseif(LUA_PLATFORM STREQUAL "c89")
    set(LUA_SYSCFLAGS "-DLUA_USE_C89")
    set(CMAKE_C_STANDARD 89)
elseif(LUA_PLATFORM STREQUAL "ios")
    set(LUA_SYSCFLAGS "-DLUA_USE_IOS")
endif()

# Combine all flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${LUA_CFLAGS} ${LUA_SYSCFLAGS} ${LUA_MYCFLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LUA_SYSLDFLAGS} ${LUA_MYLDFLAGS}")

# Source files (equivalent to CORE_O and LIB_O)
set(LUA_CORE_SRCS
        lapi.c lcode.c lctype.c ldebug.c ldo.c ldump.c lfunc.c lgc.c
        llex.c lmem.c lobject.c lopcodes.c lparser.c lstate.c lstring.c
        ltable.c ltm.c lundump.c lvm.c lzio.c lprint.c
)

set(LUA_LIB_SRCS
        lauxlib.c lbaselib.c lcorolib.c ldblib.c liolib.c lmathlib.c
        loadlib.c loslib.c lstrlib.c ltablib.c lutf8lib.c linit.c
)

# Combine core and library sources
set(LUA_BASE_SRCS ${LUA_CORE_SRCS} ${LUA_LIB_SRCS})

# Create the Lua library (equivalent to LUA_A = liblua.a)
if(LUA_PLATFORM STREQUAL "mingw")
    # For MinGW, create a DLL
    add_library(liblua SHARED ${LUA_BASE_SRCS})
    set_target_properties(liblua PROPERTIES
            OUTPUT_NAME "lua54"
            SUFFIX ".dll"
    )
else()
    # For other platforms, create a static library
    add_library(liblua STATIC ${LUA_BASE_SRCS})
    set_target_properties(liblua PROPERTIES
            OUTPUT_NAME "lua"
            ARCHIVE_OUTPUT_NAME "lua"
    )
endif()

# Special compilation flags for specific files
set_source_files_properties(llex.c lparser.c lcode.c
        PROPERTIES COMPILE_FLAGS "${LUA_CMCFLAGS}")

# Platform-specific libraries
if(LUA_SYSLIBS)
    # Parse the library flags
    string(REPLACE " " ";" LUA_SYSLIBS_LIST ${LUA_SYSLIBS})
    foreach(lib ${LUA_SYSLIBS_LIST})
        if(lib MATCHES "^-l(.+)")
            target_link_libraries(liblua ${CMAKE_MATCH_1})
        elseif(lib MATCHES "^-Wl,")
            target_link_options(liblua PUBLIC ${lib})
        endif()
    endforeach()
endif()

# User-defined libraries
if(LUA_MYLIBS)
    target_link_libraries(liblua ${LUA_MYLIBS})
endif()

# Create the Lua interpreter (equivalent to LUA_T = lua)
add_executable(lua lua.c)
target_link_libraries(lua liblua)

# Create the Lua compiler (equivalent to LUAC_T = luac)
add_executable(luac luac.c)
target_link_libraries(luac liblua)

# Platform-specific executable configuration
if(LUA_PLATFORM STREQUAL "mingw")
    set_target_properties(lua PROPERTIES OUTPUT_NAME "lua")
    set_target_properties(luac PROPERTIES OUTPUT_NAME "luac")
endif()

# Installation rules
# Headers to install
set(LUA_HEADERS
        lua.h luaconf.h lualib.h lauxlib.h lua.hpp
)

# Install binaries
install(TARGETS lua luac
        RUNTIME DESTINATION bin
        COMPONENT Runtime
)

# Install library
install(TARGETS liblua
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        COMPONENT Development
)

# Install headers
install(FILES ${LUA_HEADERS}
        DESTINATION include
        COMPONENT Development
)

# Install man pages (if they exist)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../doc/lua.1")
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/../doc/lua.1"
            "${CMAKE_CURRENT_SOURCE_DIR}/../doc/luac.1"
            DESTINATION man/man1
            COMPONENT Documentation
    )
endif()

# Create directories for Lua modules
install(CODE "
    file(MAKE_DIRECTORY 
        \"\${CMAKE_INSTALL_PREFIX}/share/lua/${LUA_VERSION}\"
        \"\${CMAKE_INSTALL_PREFIX}/lib/lua/${LUA_VERSION}\"
    )
" COMPONENT Runtime)

# Custom target for dependency checking (equivalent to depend target)
add_custom_target(depend
        COMMAND ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS} -MM l*.c
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating dependencies"
)

# Display configuration information
message(STATUS "Lua platform: ${LUA_PLATFORM}")
message(STATUS "System C flags: ${LUA_SYSCFLAGS}")
message(STATUS "System libraries: ${LUA_SYSLIBS}")
message(STATUS "Final C flags: ${CMAKE_C_FLAGS}")
message(STATUS "Final linker flags: ${CMAKE_EXE_LINKER_FLAGS}")
