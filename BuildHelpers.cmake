# Helper functions for the cmake build process to build executables or static libraries
#
# Usage:
#
# MODIFY_SCOPE( name ) in source directories
#
# ADD_TARGET( ... files ... ) for an executable
# LINK_TARGET( ... deps ... ) for executable dependencies
# ADD_STATIC_LIB( .. files ... ) to build a static lib
#

# TODO: add errors for  missing cpp files / wrong directory structure!

OPTION( WITH_TIDY "Run clang-tidy during the build, if clang is the compiler" ON)


MACRO( MODIFY_SCOPE addto )
  IF( NOT BUILD_SCOPE )
    SET ( BUILD_SCOPE ${addto} )
    SET ( BUILD_SCOPEDIR ${addto} )
  ELSE( NOT BUILD_SCOPE )
    SET( BUILD_SCOPE "${BUILD_SCOPE}-${addto}" )
    SET( BUILD_SCOPEDIR "${BUILD_SCOPEDIR}/${addto}" )
  ENDIF( NOT BUILD_SCOPE )
ENDMACRO( MODIFY_SCOPE )



MACRO( INTERNAL_HEADERS_FOR_IDES )
  FILE( GLOB_RECURSE ${BUILD_SCOPE}-headers 
    *.hxx 
    "${CMAKE_CURRENT_BINARY_DIR}/*.hxx"     
    "${CMAKE_CURRENT_SOURCE_DIR}/../include/*.hxx" 
    "${CMAKE_CURRENT_SOURCE_DIR}/../internal_include/*.hxx" 
    "${CMAKE_PROJECT_SOURCE_DIR}/assets/${BUILD_SCOPEDIR}*.glsl" 
  )
ENDMACRO()



MACRO ( COMMON_TARGET_PROPERTIES )
  IF (NOT MSVC )
    SET_PROPERTY(TARGET ${BUILD_SCOPE} PROPERTY CXX_STANDARD 17 )
    SET_PROPERTY(TARGET ${BUILD_SCOPE} PROPERTY CXX_STANDARD_REQUIRED ON )
    SET_PROPERTY(TARGET ${BUILD_SCOPE} PROPERTY CXX_EXTENSIONS OFF )
  ENDIF ()

  TARGET_INCLUDE_DIRECTORIES(${BUILD_SCOPE} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../include)
  TARGET_INCLUDE_DIRECTORIES(${BUILD_SCOPE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../internal_include)

  IF( MSVC )
    TARGET_COMPILE_OPTIONS( ${BUILD_SCOPE} PRIVATE "/std:c++latest" ) # allow experimental C++17
  ENDIF()
  
  IF ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT MSVC AND WITH_TIDY )
    SET_PROPERTY( TARGET ${BUILD_SCOPE} PROPERTY CXX_CLANG_TIDY "clang-tidy")
  ENDIF()

  IF ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU" AND NOT MSVC)
    TARGET_COMPILE_OPTIONS( ${BUILD_SCOPE} PRIVATE "-Wextra" )
    TARGET_COMPILE_OPTIONS( ${BUILD_SCOPE} PRIVATE "-Werror" )
    TARGET_LINK_LIBRARIES( ${BUILD_SCOPE} "c++experimental" )
  ENDIF()
  IF (MSVC)
    TARGET_COMPILE_OPTIONS( ${BUILD_SCOPE} PRIVATE "/W4" )
    TARGET_COMPILE_OPTIONS( ${BUILD_SCOPE} PRIVATE "/WX" )
    TARGET_COMPILE_OPTIONS( ${BUILD_SCOPE} PRIVATE "/D_WIN32_WINNT=0x0501" )
  ENDIF ()

  GroupInVisualStudio()

  TARGET_LINK_LIBRARIES( ${BUILD_SCOPE} ${CANCELLAR_THIRD_PARTY_LIBRARIES} )
ENDMACRO()



# Adds an executable target with the common C++ project settings, and basic dependencies.
# This could be a test executable, or part of the main product.
# Requires every C++ source file as parameter which is part of the build.
FUNCTION( ADD_TARGET )
  INTERNAL_HEADERS_FOR_IDES()

  FOREACH(src ${ARGV})
    LIST(APPEND ${BUILD_SCOPE}-sources "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
  ENDFOREACH()

  LIST(APPEND ${BUILD_SCOPE}-all ${${BUILD_SCOPE}-sources})  
  LIST(APPEND ${BUILD_SCOPE}-all ${${BUILD_SCOPE}-headers})
  ADD_EXECUTABLE( ${BUILD_SCOPE} ${${BUILD_SCOPE}-all} )
  
  COMMON_TARGET_PROPERTIES()
ENDFUNCTION( ADD_TARGET )



MACRO( SET_MAIN_TARGET )
  IF( "${ARGV0}" STREQUAL "" )
    SET( "${BUILD_SCOPE}_BINARY" "bin" )
  ELSE()
    SET( "${BUILD_SCOPE}_BINARY" "${ARGV0}" )
  ENDIF()
  INSTALL( TARGETS "${BUILD_SCOPE}" DESTINATION "${${BUILD_SCOPE}_BINARY}" )
  SET_TARGET_PROPERTIES( "${BUILD_SCOPE}" PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${${BUILD_SCOPE}_BINARY}" )
  SET_TARGET_PROPERTIES( "${BUILD_SCOPE}" PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${${BUILD_SCOPE}_BINARY}" )
  # TODO: copy assets
ENDMACRO()



MACRO( ADD_MAIN_TARGET )
  ADD_TARGET( ${ARGV} )
  SET_MAIN_TARGET()
ENDMACRO()



MACRO( ADD_TEST_TARGET )
  ADD_TARGET( ${ARGV} )
  SET_MAIN_TARGET( "test" )
  ADD_TEST(NAME "${BUILD_SCOPE}" COMMAND "${BUILD_SCOPE}" )
  TARGET_LINK_LIBRARIES( ${BUILD_SCOPE} ${CANCELLAR_TEST_THIRD_PARTY_LIBRARIES} )
ENDMACRO()

MACRO( ADD_HAYAI_TEST_TARGET )
  IF(NOT CMAKE_BUILD_TYPE MATCHES DEBUG)
    ADD_TARGET( ${ARGV} )
    SET_MAIN_TARGET( "test" )
    ADD_TEST(NAME "${BUILD_SCOPE}" WORKING_DIRECTORY "${CANCELLAR_BUILD_BINARY_DIR}" COMMAND "$<TARGET_FILE:${BUILD_SCOPE}>" "-o" "json:${BUILD_SCOPE}.json" "-o" "console")
    IF(MSVC)
      # Hayai issue on windows
      TARGET_COMPILE_DEFINITIONS( ${BUILD_SCOPE} PRIVATE _CRT_SECURE_NO_WARNINGS)
    ENDIF()
    TARGET_LINK_LIBRARIES( ${BUILD_SCOPE} ${CANCELLAR_TEST_THIRD_PARTY_LIBRARIES} hayai )
  ENDIF()
ENDMACRO()


MACRO( LINK_TARGET )
  SET( MYLIBS ${ARGV} )
  TARGET_LINK_LIBRARIES(${BUILD_SCOPE} ${MYLIBS})
ENDMACRO( LINK_TARGET )



MACRO( ADD_STATIC_LIB )
  INTERNAL_HEADERS_FOR_IDES()

  FOREACH(src ${ARGV})
    LIST(APPEND ${BUILD_SCOPE}-sources "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
  ENDFOREACH()
  LIST(APPEND ${BUILD_SCOPE}-all ${${BUILD_SCOPE}-sources})
  LIST(APPEND ${BUILD_SCOPE}-all ${${BUILD_SCOPE}-headers})
  ADD_LIBRARY( ${BUILD_SCOPE} STATIC ${${BUILD_SCOPE}-all})
  SET_PROPERTY( TARGET ${BUILD_SCOPE} PROPERTY POSITION_INDEPENDENT_CODE ON )

  COMMON_TARGET_PROPERTIES()
ENDMACRO( ADD_STATIC_LIB )

MACRO( ADD_SHARED_LIB )
  INTERNAL_HEADERS_FOR_IDES()

  FOREACH(src ${ARGV})
    LIST(APPEND ${BUILD_SCOPE}-sources "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
  ENDFOREACH()
  LIST(APPEND ${BUILD_SCOPE}-all ${${BUILD_SCOPE}-sources})
  LIST(APPEND ${BUILD_SCOPE}-all ${${BUILD_SCOPE}-headers})
  ADD_LIBRARY( ${BUILD_SCOPE} SHARED ${${BUILD_SCOPE}-all})
  SET_PROPERTY( TARGET ${BUILD_SCOPE} PROPERTY POSITION_INDEPENDENT_CODE ON )

  COMMON_TARGET_PROPERTIES()
ENDMACRO( ADD_SHARED_LIB )
