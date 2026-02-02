FILE(GLOB SRC *.cpp *.h)

ADD_EXECUTABLE(mtp-target-forever-ls WIN32 ${SRC})

INCLUDE_DIRECTORIES(
		${LIBXML2_INCLUDE_DIR}
		${NEL_INCLUDE_DIR}
		${MYSQL_INCLUDE_DIR})

IF(WIN32)
	TARGET_LINK_LIBRARIES(mtp-target-forever-ls	optimized ${NELMISC_LIBRARY}	debug ${NELMISC_LIBRARY_DEBUG} 
										optimized ${NELNET_LIBRARY}		debug ${NELNET_LIBRARY_DEBUG} 
										${PLATFORM_LINKFLAGS}
										${MYSQL_LIBRARIES}
										${ZLIB_LIBRARY}
										${FREETYPE_LIBRARY}
										${PNG_LIBRARY}
										${JPEG_LIBRARY})

	SET_TARGET_PROPERTIES(mtp-target-forever-ls PROPERTIES 
		PROJECT_LABEL "Server: MTP Target Forever LS"
		LINK_FLAGS_DEBUG "/NODEFAULTLIB:libc;libcmt;libcmtd;msvcrt"
		LINK_FLAGS_RELEASE "/NODEFAULTLIB:libc;libcmt;libcmtd;msvcrtd")
ELSE(WIN32)
	TARGET_LINK_LIBRARIES(mtp-target-forever-ls	${NELMISC_LIBRARY} 
										${NELNET_LIBRARY} 
										${PLATFORM_LINKFLAGS}
										${MYSQL_LIBRARIES}
										${ZLIB_LIBRARY})
ENDIF(WIN32)

ADD_DEFINITIONS(-DMT_SERVER -DMTPT_SERVER)

INSTALL(TARGETS mtp-target-forever-ls RUNTIME DESTINATION games)
INSTALL(FILES login_service.cfg DESTINATION games)
