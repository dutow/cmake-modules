# Finds XCB includes and libraries

INCLUDE_GUARD()

IF( CANCELLAR_PLATFORM_LINUX )
  FIND_PACKAGE( XCB REQUIRED )
  LIST( APPEND CANCELLAR_THIRD_PARTY_INCLUDES "${XCB_INCLUDE_DIR}" )
  LIST( APPEND CANCELLAR_THIRD_PARTY_LIBRARIES "${XCB_LIBRARIES}" )
ENDIF()

