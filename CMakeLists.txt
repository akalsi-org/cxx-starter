cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Project --------------------------------------------------------------
get_filename_component(PROJ_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" PROJ_NAME ${PROJ_NAME})

# Note: update this to your new project's name and version
project(
  ${PROJ_NAME}
  VERSION 1.0
  LANGUAGES C CXX)

# ---- Include guards --------------------------------------------------------
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()

# ---- Add dependencies via CPM ----------------------------------------------
include(cmake/CPM.cmake)

# PackageProject.cmake will be used to make our target installable
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")

# Dev dependencies
CPMAddPackage("gh:onqtam/doctest#2.4.5")

# ---- Add dependencies via vcpkg --------------------------------------------
find_package(absl CONFIG REQUIRED)
# target_link_libraries(main PRIVATE absl::any absl::base absl::bits absl::city)

find_package(date CONFIG REQUIRED)
# target_link_libraries(main PRIVATE date::date date::date-tz)

find_package(fmt CONFIG REQUIRED)
# target_link_libraries(main PRIVATE fmt::fmt)

# Or use the header-only version find_package(fmt CONFIG REQUIRED)
# target_link_libraries(main PRIVATE fmt::fmt-header-only)

find_package(Microsoft.GSL CONFIG REQUIRED)
# target_link_libraries(main PRIVATE Microsoft.GSL::GSL)

find_package(spdlog CONFIG REQUIRED)
# target_link_libraries(main PRIVATE spdlog::spdlog spdlog::spdlog_header_only)

# ---- Enable testing -------------------------------------------------------
enable_testing()

# ---- Include target definition funcs --------------------------------------
include(cmake/define-targets.cmake)
