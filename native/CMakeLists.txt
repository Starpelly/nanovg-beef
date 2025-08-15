cmake_minimum_required(VERSION 3.15)
project(nanovg C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(VENDOR_DIR ${CMAKE_CURRENT_SOURCE_DIR}/vendor)

option(BUILD_STATIC "Build a static library instead of shared" OFF)

include_directories(
    ${SOURCE_DIR}
    ${VENDOR_DIR}
    ${VENDOR_DIR}/nanovg/src
)

set(NANOVG_SRC
    ${VENDOR_DIR}/nanovg/src/nanovg.c
)

# ---- Determine library type and set output name ----
if(BUILD_STATIC)
    set(LIB_TYPE STATIC)
    set(LIB_SUFFIX "_static")
    add_definitions(-DNANO_BUILD_STATIC)
else()
    set(LIB_TYPE SHARED)
    set(LIB_SUFFIX "_shared")
    add_definitions(-DNANO_BUILD_SHARED)
endif()

# ---- Platform string for output directory ----
if(WIN32)
    set(PLATFORM_NAME "windows")
elseif(APPLE)
    set(PLATFORM_NAME "mac")
elseif(UNIX)
    set(PLATFORM_NAME "linux")
else()
    set(PLATFORM_NAME "unknown")
endif()

# ---- Build the library ----
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
add_library(${PROJECT_NAME} STATIC
    ${SOURCE_DIR}/main.c
    ${NANOVG_SRC}
)

# Post-build copy to ../libs/<platform>/<config>
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${PLATFORM_NAME}/$<CONFIG>"
    COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE:${PROJECT_NAME}>"
        "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${PLATFORM_NAME}/$<CONFIG>/$<TARGET_NAME:${PROJECT_NAME}>${LIB_SUFFIX}$<TARGET_FILE_SUFFIX:${PROJECT_NAME}>"
)

# ---- Platform-specific OpenGL / system libs ----
if (APPLE)
    target_link_libraries(${PROJECT_NAME} "-framework OpenGL" "-framework Cocoa" "-framework IOKit" "-framework CoreVideo")
elseif(UNIX)
    find_package(OpenGL REQUIRED)
    target_link_libraries(${PROJECT_NAME} m pthread GL dl rt)
elseif(WIN32)
    target_link_libraries(${PROJECT_NAME} opengl32 gdi32 winmm)
endif()

# ---- Compile warnings ----
if (MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W3)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)
endif()