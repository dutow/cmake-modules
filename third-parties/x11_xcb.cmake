# Finds X11-XCB includes and libraries

INCLUDE_GUARD()

IF( CANCELLAR_PLATFORM_LINUX )
  FIND_PACKAGE( X11_XCB REQUIRED )
  LIST( APPEND CANCELLAR_THIRD_PARTY_INCLUDES "${X11_XCB_INCLUDE_DIR}" )
  LIST( APPEND CANCELLAR_THIRD_PARTY_LIBRARIES "${X11_XCB_LIBRARIES}" )
ENDIF()
