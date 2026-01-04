# find SSLEAY includes and library
#
# SSLEAY_LIBRARY     - full path to the SSLEAY (SSL) library
# EAY_LIBRARY        - full path to the EAY (crypto) library
# SSLEAY_FOUND       - TRUE if SSLEAY was found
#
# Updated to support modern OpenSSL 1.1.x naming (libssl, libcrypto)
# and OPENSSL_ROOT_DIR path hint

IF (NOT SSLEAY_FOUND)

  # Build list of search paths
  SET(SSLEAY_SEARCH_PATHS
    ${OPENSSL_ROOT_DIR}/lib/VC
    ${OPENSSL_ROOT_DIR}/lib
    ${CMAKE_PREFIX_PATH}/openssl/lib/VC
    ${CMAKE_PREFIX_PATH}/openssl/lib
    /usr/lib
    /usr/local/lib
  )

  # Find SSL library (old names: ssleay32, new names: libssl)
  FIND_LIBRARY(SSLEAY_LIBRARY
    NAMES libssl64MD libssl libssl-1_1-x64 ssl ssleay ssleay32 libssleay32 libssleay
    PATHS ${SSLEAY_SEARCH_PATHS}
  )

  IF(SSLEAY_LIBRARY)
    MESSAGE(STATUS "Found SSLEAY library: ${SSLEAY_LIBRARY}")
  ELSE(SSLEAY_LIBRARY)
    MESSAGE(STATUS "Could NOT find SSLEAY library.")
  ENDIF(SSLEAY_LIBRARY)

  # Find crypto library (old names: libeay32, new names: libcrypto)
  FIND_LIBRARY(EAY_LIBRARY
    NAMES libcrypto64MD libcrypto libcrypto-1_1-x64 crypto eay eay32 libeay32 libeay
    PATHS ${SSLEAY_SEARCH_PATHS}
  )

  IF(EAY_LIBRARY)
    MESSAGE(STATUS "Found EAY library: ${EAY_LIBRARY}")
  ELSE(EAY_LIBRARY)
    MESSAGE(STATUS "Could NOT find EAY library.")
  ENDIF(EAY_LIBRARY)

  IF(EAY_LIBRARY AND SSLEAY_LIBRARY)
     SET(SSLEAY_FOUND TRUE CACHE STRING "Whether SSLEAY was found or not")
   ELSE(EAY_LIBRARY AND SSLEAY_LIBRARY)
     SET(SSLEAY_FOUND FALSE)
     IF(SSLEAY_FIND_REQUIRED)
       MESSAGE(FATAL_ERROR "Could not find SSLEAY. Please install SSLEAY")
     ENDIF(SSLEAY_FIND_REQUIRED)
   ENDIF(EAY_LIBRARY AND SSLEAY_LIBRARY)
ENDIF (NOT SSLEAY_FOUND)
