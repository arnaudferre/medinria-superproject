##############################################################################
#
# medInria
#
# Copyright (c) INRIA 2013. All rights reserved.
# See LICENSE.txt for details.
# 
#  This software is distributed WITHOUT ANY WARRANTY; without even
#  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#  PURPOSE.
#
################################################################################


## #############################################################################
## Get distribution name and architecture
## #############################################################################

execute_process(COMMAND lsb_release -irs
  COMMAND sed "s/ //"
  COMMAND sed "s/Fedora/fc/"
  COMMAND tr -d '\n' 
  OUTPUT_VARIABLE DISTRIB
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  
execute_process(COMMAND arch 
  OUTPUT_VARIABLE ARCH 
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  
set(CPACK_PACKAGE_FILE_NAME 
  "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${DISTRIB}-${ARCH}"
  )

 
## #############################################################################
## Set right package generator
## #############################################################################

if(${DISTRIB} MATCHES fc|fedora|Centos|centos|SUSE|Suse|suse)
  set(CPACK_GENERATOR RPM)
else()
  set(CPACK_GENERATOR DEB)
endif()

set(CPACK_GENERATOR "${CPACK_GENERATOR}" CACHE STRING "Type of package to build")
mark_as_advanced(CPACK_GENERATOR)

## #############################################################################
## Set directory where the package will be installed
## #############################################################################

set (CPACK_PACKAGING_INSTALL_PREFIX /usr/local/medInria CACHE 
  STRING "Prefix where the package will be installed"
  )
mark_as_advanced(CPACK_PACKAGING_INSTALL_PREFIX) 

## #############################################################################
## Add postinst and prerm script
## #############################################################################
 
configure_file(${CMAKE_SOURCE_DIR}/packaging/linux/postinst.in 
  ${CMAKE_BINARY_DIR}/packaging/linux/postinst
  )
  
configure_file(${CMAKE_SOURCE_DIR}/packaging/linux/prerm.in 
  ${CMAKE_BINARY_DIR}/packaging/linux/prerm
  )

# DEB
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA 
  ${CMAKE_BINARY_DIR}/packaging/linux/prerm;
  ${CMAKE_BINARY_DIR}/packaging/linux/postinst
  )

# RPM  
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE ${CMAKE_BINARY_DIR}/packaging/linux/postinst)
set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE ${CMAKE_BINARY_DIR}/packaging/linux/prerm)


## #############################################################################
## Add a small project to install medInria_launcher.sh
## #############################################################################

add_subdirectory(${CMAKE_SOURCE_DIR}/packaging/linux)


## #############################################################################
## Add project to package
## #############################################################################

 
set(CPACK_INSTALL_CMAKE_PROJECTS ${CPACK_INSTALL_CMAKE_PROJECTS};
  ${CMAKE_BINARY_DIR}/packaging/linux;
  medInria_launcher;
  ALL;
  medInria_launcher
  )
   
foreach(external_project ${external_projects}) 
	if(NOT USE_SYSTEM_${external_project} AND BUILD_SHARED_LIBS_${external_project})
		ExternalProject_Get_Property(${external_project} binary_dir)
		
		set(CPACK_INSTALL_CMAKE_PROJECTS ${CPACK_INSTALL_CMAKE_PROJECTS};
		   ${binary_dir};
		   ${external_project};
		   ALL;
		   ${external_project}
		  )
	endif()
endforeach()

foreach(dir ${PRIVATE_PLUGINS_DIRS})
	set(CPACK_INSTALL_CMAKE_PROJECTS  ${CPACK_INSTALL_CMAKE_PROJECTS};
    ${dir};
    ${dir};
    ALL;
    ${dir}
    )
endforeach()