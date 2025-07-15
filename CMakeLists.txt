cmake_minimum_required(VERSION 3.10)

# Lua version and release
set(LUA_VERSION "5.4")
set(LUA_RELEASE "5.4.8")

project(lua VERSION ${LUA_RELEASE})

# Platform detection (equivalent to PLAT= guess)
if(NOT DEFINED LUA_PLATFORM)
    if(UNIX AND NOT APPLE)
        if(CMAKE_SYSTEM_NAME MATCHES "Linux")
            set(LUA_PLATFORM "linux")
        elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
            set(LUA_PLATFORM "freebsd")
        elseif(CMAKE_SYSTEM_NAME MATCHES "SunOS")
            set(LUA_PLATFORM "solaris")
        else()
            set(LUA_PLATFORM "posix")
        endif()
    elseif(APPLE)
        set(LUA_PLATFORM "macosx")
    elseif(WIN32)
        set(LUA_PLATFORM "mingw")
    else()
        set(LUA_PLATFORM "generic")
    endif()
endif()

# Installation directories (equivalent to INSTALL_* variables)
set(LUA_INSTALL_BIN "${CMAKE_INSTALL_PREFIX}/bin")
set(LUA_INSTALL_INC "${CMAKE_INSTALL_PREFIX}/include")
set(LUA_INSTALL_LIB "${CMAKE_INSTALL_PREFIX}/lib")
set(LUA_INSTALL_MAN "${CMAKE_INSTALL_PREFIX}/man/man1")
set(LUA_INSTALL_LMOD "${CMAKE_INSTALL_PREFIX}/share/lua/${LUA_VERSION}")
set(LUA_INSTALL_CMOD "${CMAKE_INSTALL_PREFIX}/lib/lua/${LUA_VERSION}")

# Files to install (equivalent to TO_* variables)
set(LUA_TO_BIN lua luac)
set(LUA_TO_INC lua.h luaconf.h lualib.h lauxlib.h lua.hpp)
set(LUA_TO_LIB liblua.a)
set(LUA_TO_MAN lua.1 luac.1)

# Add the src subdirectory where the actual build happens
add_subdirectory(src)

# Custom target for help (equivalent to help target)
#add_custom_target(help
#        COMMAND ${CMAKE_COMMAND} -E echo "Available platforms: ${AVAILABLE_PLATFORMS}"
#        COMMAND ${CMAKE_COMMAND} -E echo "See doc/readme.html for complete instructions."
#        COMMENT "Showing help information"
#)

# Custom target for test (equivalent to test target)
add_custom_target(test_lua
        COMMAND $<TARGET_FILE:lua> -v
        DEPENDS lua
        COMMENT "Running Lua version test"
)

# Custom target for echo (equivalent to echo target)
add_custom_target(echo
        COMMAND ${CMAKE_MAKE_PROGRAM} -s echo
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src
        COMMAND ${CMAKE_COMMAND} -E echo "PLAT= ${LUA_PLATFORM}"
        COMMAND ${CMAKE_COMMAND} -E echo "V= ${LUA_VERSION}"
        COMMAND ${CMAKE_COMMAND} -E echo "R= ${LUA_RELEASE}"
        COMMAND ${CMAKE_COMMAND} -E echo "TO_BIN= ${LUA_TO_BIN}"
        COMMAND ${CMAKE_COMMAND} -E echo "TO_INC= ${LUA_TO_INC}"
        COMMAND ${CMAKE_COMMAND} -E echo "TO_LIB= ${LUA_TO_LIB}"
        COMMAND ${CMAKE_COMMAND} -E echo "TO_MAN= ${LUA_TO_MAN}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_TOP= ${CMAKE_INSTALL_PREFIX}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_BIN= ${LUA_INSTALL_BIN}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_INC= ${LUA_INSTALL_INC}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_LIB= ${LUA_INSTALL_LIB}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_MAN= ${LUA_INSTALL_MAN}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_LMOD= ${LUA_INSTALL_LMOD}"
        COMMAND ${CMAKE_COMMAND} -E echo "INSTALL_CMOD= ${LUA_INSTALL_CMOD}"
        COMMENT "Echoing configuration parameters"
)

# Custom target for pkg-config data (equivalent to pc target)
add_custom_target(pc
        COMMAND ${CMAKE_COMMAND} -E echo "version=${LUA_RELEASE}"
        COMMAND ${CMAKE_COMMAND} -E echo "prefix=${CMAKE_INSTALL_PREFIX}"
        COMMAND ${CMAKE_COMMAND} -E echo "libdir=${LUA_INSTALL_LIB}"
        COMMAND ${CMAKE_COMMAND} -E echo "includedir=${LUA_INSTALL_INC}"
        COMMENT "Echoing pkg-config data"
)

# Installation rules - now handled by src/CMakeLists.txt
# The actual targets and installation rules are defined in src/CMakeLists.txt

# Custom target for local install (equivalent to local target)
add_custom_target(local_install
        COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_SOURCE_DIR}/install -P cmake_install.cmake
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Installing to local directory"
)

# Print helpful information
message(STATUS "Lua version: ${LUA_RELEASE}")
message(STATUS "Platform: ${LUA_PLATFORM}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

# Define available platforms for reference
set(AVAILABLE_PLATFORMS "guess;aix;bsd;c89;freebsd;generic;ios;linux;linux-readline;macosx;mingw;posix;solaris")
message(STATUS "Available platforms: ${AVAILABLE_PLATFORMS}")

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
