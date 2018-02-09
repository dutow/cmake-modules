# Common vendor related macros

INCLUDE_GUARD()

MACRO( DEFINE_BUILD_PRESET PRESET_NAME)
  SET( CANCELLAR_CURRENT_PRESET "${PRESET_NAME}")
  ADD_LIBRARY( "PRESET_${PRESET_NAME}" INTERFACE )
  ADD_LIBRARY( "PRESET_${PRESET_NAME}_TEST" INTERFACE )
  TARGET_LINK_LIBRARIES( "PRESET_${CANCELLAR_CURRENT_PRESET}_TEST" INTERFACE "PRESET_${CANCELLAR_CURRENT_PRESET}" )
ENDMACRO()

MACRO( INTERNAL_PRESET_DEPENDENCY LIBNAME )
  TARGET_LINK_LIBRARIES( "PRESET_${CANCELLAR_CURRENT_PRESET}" INTERFACE "${LIBNAME}" )
ENDMACRO()

MACRO( ADD_VENDOR_INCLUDES )
  INCLUDE_DIRECTORIES( ${CANCELLAR_VENDOR_INCLUDES} )
ENDMACRO()

MACRO( ADD_TEST_INCLUDES )
  INCLUDE_DIRECTORIES( ${CANCELLAR_TEST_INCLUDES} )
ENDMACRO()

MACRO( APPEND_VENDOR_LIBRARIES )
  LIST( APPEND CANCELLAR_VENDOR_LIBRARIES ${ARGV} )
ENDMACRO()

MACRO( APPEND_TEST_VENDOR_LIBRARIES )
  LIST( APPEND CANCELLAR_TEST_VENDOR_LIBRARIES ${ARGV} )
ENDMACRO()

MACRO ( __INTERNAL_SINGLE_HEADER_ONLY NAME VENDOR_DIR )
  IF( NOT EXISTS "${CANCELLAR_BUILD_VENDOR_DIR}${VENDOR_DIR}/" )
    MESSAGE( FATAL_ERROR "${NAME} diretory doesn't exists: ${CANCELLAR_BUILD_VENDOR_DIR}${VENDOR_DIR}!" )
  ENDIF()
  
  ADD_LIBRARY( "${NAME}" INTERFACE )
  TARGET_INCLUDE_DIRECTORIES( "${NAME}" INTERFACE "${CANCELLAR_BUILD_VENDOR_DIR}${VENDOR_DIR}/" )
ENDMACRO()

MACRO( INTERNAL_DEFAULT_SINGLE_HEADER_ONLY_LIBRARY NAME VENDOR_DIR )
  __INTERNAL_SINGLE_HEADER_ONLY( "${NAME}" "${VENDOR_DIR}" )
  TARGET_LINK_LIBRARIES( "PRESET_${CANCELLAR_CURRENT_PRESET}" INTERFACE "${NAME}" )
ENDMACRO()

MACRO( INTERNAL_HEADER_ONLY_LIBRARY NAME VENDOR_DIR )
  __INTERNAL_SINGLE_HEADER_ONLY( "${NAME}" "${VENDOR_DIR}" )
  TARGET_LINK_LIBRARIES( "PRESET_${CANCELLAR_CURRENT_PRESET}" INTERFACE "${NAME}" )
ENDMACRO()

MACRO( INTERNAL_TEST_SINGLE_HEADER_ONLY_LIBRARY NAME VENDOR_DIR )
  __INTERNAL_SINGLE_HEADER_ONLY( "${NAME}" "${VENDOR_DIR}" )
  TARGET_LINK_LIBRARIES( "PRESET_${CANCELLAR_CURRENT_PRESET}_TEST" INTERFACE "${NAME}" )
ENDMACRO()

