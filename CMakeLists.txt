#-----------------------------------------------------------------------------
#
# MTP Target
#    Author: Vialek
#
# Notes:
#   * Changing install location: add -DCMAKE_INSTALL_PREFIX:PATH=/my/new/path
#   * Changing NeL prefix: add -DNEL_PREFIX_PATH:PATH=/my/nel/install
#
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Load some macros.
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMakeModules;${CMAKE_MODULE_PATH}")
INCLUDE(CMakeModules/nel.cmake)

#-----------------------------------------------------------------------------
# Force out of source builds.
CHECK_OUT_OF_SOURCE()

IF(WIN32)
  SET(CMAKE_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/../3rdParty/include;${CMAKE_INCLUDE_PATH}")
  SET(CMAKE_LIBRARY_PATH "${CMAKE_SOURCE_DIR}/../3rdParty/lib;${CMAKE_LIBRARY_PATH}")
ENDIF(WIN32)

IF(DEFINED NEL_PREFIX_PATH)
  SET(CMAKE_INCLUDE_PATH "${NEL_PREFIX_PATH}/include;${CMAKE_INCLUDE_PATH}")
  SET(CMAKE_LIBRARY_PATH "${NEL_PREFIX_PATH}/lib;${CMAKE_LIBRARY_PATH}")
ENDIF(DEFINED NEL_PREFIX_PATH)

CMAKE_MINIMUM_REQUIRED(VERSION 3.5)

PROJECT(MTP-Target-Forever CXX C)
SET(MTPF_VERSION_MAJOR 1)
SET(MTPF_VERSION_MINOR 19)
SET(MTPF_VERSION_PATCH 0)
SET(MTPF_VERSION "${MTPF_VERSION_MAJOR}.${MTPF_VERSION_MINOR}.${MTPF_VERSION_PATCH}")

#-----------------------------------------------------------------------------
# Redirect output files
SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
SET(LIBRARY_OUTPUT_PATH  ${CMAKE_BINARY_DIR}/lib)

#-----------------------------------------------------------------------------
# Set CMake 2.6 Policies.
IF(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
ENDIF(COMMAND cmake_policy)


#-----------------------------------------------------------------------------
# Set default config options
#
NL_SETUP_DEFAULT_OPTIONS()
NL_SETUP_PREFIX_PATHS()

#-----------------------------------------------------------------------------
# Override default options

OPTION(BUILD_CLIENT "Build the MTP Target Forever Client" ON)
OPTION(BUILD_SERVER "Build the MTP Target Forever Servers" ON)

SET(MTP_TARGET_CONFIG_DIR "${NL_ETC_PREFIX}/mtp-target-forever" CACHE FILEPATH "MTP Target Forever config file location")
SET(MTP_TARGET_DATA_DIR "${NL_SHARE_PREFIX}/games/mtp-target-forever" CACHE FILEPATH "MTP Target Forever data file location")

#-----------------------------------------------------------------------------
#Platform specifics

FIND_PACKAGE(Threads REQUIRED)
FIND_PACKAGE(LibXml2 REQUIRED)
FIND_PACKAGE(ZLIB REQUIRED)

NL_SETUP_BUILD()

FIND_PACKAGE(NeL COMPONENTS nelmisc nelnet nel3d REQUIRED)

IF(BUILD_CLIENT)
    FIND_PACKAGE(CURL REQUIRED)
    FIND_PACKAGE(Lua50 REQUIRED)
    FIND_PACKAGE(NeL COMPONENTS nelsound nelsnd_lowlevel nelgeorges nelligo REQUIRED)
    IF(WIN32)
	FIND_PACKAGE(Jpeg)
	FIND_PACKAGE(PNG)
	FIND_PACKAGE(FreeType)
	FIND_PACKAGE(SSLEAY REQUIRED)
    ENDIF(WIN32)
ENDIF(BUILD_CLIENT)

IF(BUILD_SERVER)
    FIND_PACKAGE(ODE REQUIRED)
    FIND_PACKAGE(MySQL)
ENDIF(BUILD_SERVER)

NL_SETUP_BUILD_FLAGS()

ADD_DEFINITIONS(-DMTP_TARGET_CONFIG_DIR="${MTP_TARGET_CONFIG_DIR}/")

IF(BUILD_CLIENT)
  ADD_SUBDIRECTORY(client)
ENDIF(BUILD_CLIENT)

IF(BUILD_SERVER)
  ADD_SUBDIRECTORY(server)
#  ADD_SUBDIRECTORY(login_service)
ENDIF(BUILD_SERVER)
