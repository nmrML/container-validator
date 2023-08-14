##################################################
###       GSL   															 ###
##################################################
## GSL from http://gnuwin32.sourceforge.net/packages/gsl.htm
## repacked installed files (deleting precompiled libraries) and created VisualStudio 2008 files

MACRO( OPENMS_CONTRIB_BUILD_GSL )
  OPENMS_LOGHEADER_LIBRARY("GSL")
  #extract: (takes very long.. so skip if possible)
  if(MSVC)
    set(ZIP_ARGS "x -y -osrc")
  else()
    set(ZIP_ARGS "xzf")
  endif(MSVC)
  OPENMS_SMARTEXTRACT(ZIP_ARGS ARCHIVE_GSL "GSL" "INSTALL")
  
  if(MSVC)
	if (CONTRIB_MSVC_VERSION STREQUAL "12")
		# patch config.h (for VS12 only, since math.h defines some functions which GSL re-defines otherwise)
		set(PATCH_FILE "${PATCH_DIR}/gsl/config.diff")
		set(PATCHED_FILE "${GSL_DIR}/config.h")
		OPENMS_PATCH( PATCH_FILE GSL_DIR PATCHED_FILE)
	endif()	
	  
    ## we need to build gsl-lib, gslcblas-lib in release and debug mode (=4 libs)
    set(MSBUILD_ARGS_SLN "${GSL_DIR}/win32_VS${CONTRIB_MSVC_VERSION}/gsl.sln")
    set(MSBUILD_ARGS_TARGET "gsl")
    OPENMS_BUILDLIB("GSL (Debug)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Debug" GSL_DIR)
    OPENMS_BUILDLIB("GSL (Release)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Release" GSL_DIR)

    set(MSBUILD_ARGS_TARGET "cblas")
    OPENMS_BUILDLIB("GSL-cblas (Debug)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Debug" GSL_DIR)
    OPENMS_BUILDLIB("GSL-cblas (Release)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Release" GSL_DIR)
  
    ## copy includes
    set(dir_target ${PROJECT_BINARY_DIR}/include/gsl)
    set(dir_source ${GSL_DIR}/win32_VS${CONTRIB_MSVC_VERSION}/include/gsl)
    OPENMS_COPYDIR(dir_source dir_target)

  else()
		# patch Makefile.in
   	set(PATCH_FILE "${PATCH_DIR}/gsl/Makefile_in.diff")
  	set(PATCHED_FILE "${GSL_DIR}/Makefile.in")
	  OPENMS_PATCH( PATCH_FILE GSL_DIR PATCHED_FILE)

		if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      set (GSL_CUSTOM_FLAGS "${CXX_OSX_FLAGS}")
		endif()
    
    # configure -- 
    set( ENV{CC} ${CMAKE_C_COMPILER} )
    set( ENV{CXX} ${CMAKE_CXX_COMPILER} )
    set( ENV{CFLAGS} ${GSL_CUSTOM_FLAGS})

		if (BUILD_SHARED_LIBRARIES)
			set(STATIC_BUILD "--enable-static=no")
			set(SHARED_BUILD "--enable-shared=yes")
		else()
			set(STATIC_BUILD "--enable-static=yes")
			set(SHARED_BUILD "--enable-shared=no")		
		endif()
		
    message( STATUS "Configure GSL library (./configure --prefix ${CMAKE_BINARY_DIR} --with-pic --disable-shared) .. ")
    exec_program("./configure" "${GSL_DIR}"
      ARGS
      --prefix ${CMAKE_BINARY_DIR}
      --with-pic
      ${STATIC_BUILD}
      ${SHARED_BUILD}
      OUTPUT_VARIABLE GSL_CONFIGURE_OUT
      RETURN_VALUE GSL_CONFIGURE_SUCCESS
      )

    # logfile
    file(APPEND ${LOGFILE} ${GSL_CONFIGURE_OUT})

    if( NOT GSL_CONFIGURE_SUCCESS EQUAL 0)
      message( STATUS "Configure GSL library (./configure --prefix ${CMAKE_BINARY_DIR} --with-pic --disable-shared) .. failed")
      message( FATAL_ERROR ${GSL_CONFIGURE_OUT})
    else()
      message( STATUS "Configure GSL library (./configure --prefix ${CMAKE_BINARY_DIR} --with-pic --disable-shared) .. done")
    endif()
  
    # make 
    message( STATUS "Building GSL library (make) .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${GSL_DIR}"
      ARGS -j ${NUMBER_OF_JOBS}
      OUTPUT_VARIABLE GSL_MAKE_OUT
      RETURN_VALUE GSL_MAKE_SUCCESS
      )

    file(APPEND ${LOGFILE} ${GSL_MAKE_OUT})

    if( NOT GSL_MAKE_SUCCESS EQUAL 0)
      message( STATUS "Building GSL library (make) .. failed")
      message( FATAL_ERROR ${GSL_MAKE_OUT})
    else()
      message( STATUS "Building GSL library (make) .. done")
    endif()

    # make install
    message( STATUS "Installing GSL library (make install) .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${GSL_DIR}"
      ARGS "install"
      -j ${NUMBER_OF_JOBS}
      OUTPUT_VARIABLE GSL_INSTALL_OUT
      RETURN_VALUE GSL_INSTALL_SUCCESS
      )

    file(APPEND ${LOGFILE} ${GSL_INSTALL_OUT})

    if( NOT GSL_INSTALL_SUCCESS EQUAL 0)
      message( STATUS "Installing GSL library (make install) .. failed")      
      message( FATAL_ERROR ${GSL_INSTALL_OUT})
    else()
      message( STATUS "Installing GSL library (make install) .. done")
    endif()
endif()

ENDMACRO( OPENMS_CONTRIB_BUILD_GSL )
