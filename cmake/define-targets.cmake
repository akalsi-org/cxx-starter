function(define_lib libName tgtLinkOpts)
  # Note: globbing sources is considered bad practice as CMake's generators may not detect new files
  # automatically. Keep that in mind when changing files, or explicitly mention them here.
  file(GLOB_RECURSE pubHdrs CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${libName}/*.h")
  file(GLOB_RECURSE pvtHdrs CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/${libName}/*.h")
  file(GLOB_RECURSE cSrc CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/${libName}/*.c")
  file(GLOB_RECURSE ccSrc CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/${libName}/*.cc")
  file(GLOB_RECURSE ccTestSrc CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/test/${PROJECT_NAME}/${libName}/*.cc")
  # Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
  # target: add_library(${libName} INTERFACE)
  add_library(${libName} ${pubHdrs} ${pvtHdrs} ${cSrc} ${ccSrc})
  set_target_properties(${libName} PROPERTIES OUTPUT_NAME "${PROJECT_NAME}-${libName}")

  # Link dependencies
  target_link_libraries(${libName} ${tgtLinkOpts})

  target_include_directories(
    ${libName} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                      $<INSTALL_INTERFACE:include/${PROJECT_NAME}/${libName}>
  )
  string(TOLOWER ${libName}/version.h verHdrLoc)
  packageProject(
    NAME ${libName}
    VERSION ${PROJECT_VERSION}
    NAMESPACE ${PROJECT_NAME}
    BINARY_DIR ${PROJECT_BINARY_DIR}
    INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
    INCLUDE_DESTINATION include
    VERSION_HEADER "${verHdrLoc}"
    COMPATIBILITY SameMajorVersion
  )

  add_executable(${libName}-test ${ccTestSrc} ${PROJECT_SOURCE_DIR}/test/main.cc)
  target_link_libraries(${libName}-test doctest::doctest ${libName})
  add_test(NAME ${libName}-test COMMAND $<TARGET_FILE:${libName}-test>)
  set_target_properties(${libName}-test PROPERTIES OUTPUT_NAME "${PROJECT_NAME}-${libName}-test")

  # being a cross-platform target, we enforce standards conformance on MSVC
  target_compile_options(${libName} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")

  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    target_compile_options(${libName} PUBLIC -Wall -Wpedantic -Wextra -Werror)
  elseif(MSVC)
    target_compile_options(${libName} PUBLIC /W4 /WX)
    target_compile_definitions(${libName}-test PUBLIC DOCTEST_CONFIG_USE_STD_HEADERS)
  endif()

  if(ENABLE_TEST_COVERAGE AND "${CMAKE_BUILD_TYPE}" STREQUAL Debug)
    target_compile_options(${libName} PUBLIC -O0 -g -fprofile-arcs -ftest-coverage)
    target_link_options(${libName} PUBLIC -fprofile-arcs -ftest-coverage)
  endif()
endfunction()

function(define_exe exeName tgtLinkOpts)
  # Note: globbing sources is considered bad practice as CMake's generators may not detect new files
  # automatically. Keep that in mind when changing files, or explicitly mention them here.
  file(GLOB_RECURSE pvtHdrs CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/${exeName}/*.h")
  file(GLOB_RECURSE cSrc CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/${exeName}/*.c")
  file(GLOB_RECURSE ccSrc CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/${PROJECT_NAME}/${exeName}/*.cc")
  # Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
  # target: add_library(${libName} INTERFACE)
  add_executable(${exeName} ${pvtHdrs} ${cSrc} ${ccSrc})

  # Link dependencies
  target_link_libraries(${exeName} ${tgtLinkOpts})

  target_include_directories(${exeName} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>)

  # being a cross-platform target, we enforce standards conformance on MSVC
  target_compile_options(${exeName} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")

  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    target_compile_options(${exeName} PUBLIC -Wall -Wpedantic -Wextra -Werror)
  elseif(MSVC)
    target_compile_options(${exeName} PUBLIC /W4 /WX)
    target_compile_definitions(${exeName}-test PUBLIC DOCTEST_CONFIG_USE_STD_HEADERS)
  endif()

  install(TARGETS ${exeName} DESTINATION bin)
endfunction()
