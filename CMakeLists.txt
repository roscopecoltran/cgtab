project ( cgtab )

cmake_minimum_required ( VERSION 3.2 )

# forbid in-tree builds
if ( CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR AND NOT MSVC_IDE )
    message ( FATAL_ERROR "In-source builds are not allowed." )
endif ()

set ( THIRDPARTY_BASE_REMOTE0 "${CMAKE_SOURCE_DIR_PATENT}/repos" CACHE STRING "Path to the directory ... is located" )
set ( THIRDPARTY_BASE_REMOTE1 "/media/xyu/myusbstick" CACHE STRING "Path to the directory ... is located" )
set ( THIRDPARTY_BASE_REMOTE2 "git@github.com:myrepo" CACHE STRING "Path to the directory ... is located" )


set ( FOOBAR_REMOTE0 "${CMAKE_SOURCE_DIR_PATENT}/repos/foobar" CACHE STRING "Path to the directory ... is located" )
set ( FOOBAR_REMOTE1 "/media/xyu/myusbstick/foobar" CACHE STRING "Path to the directory ... is located" )
set ( FOOBAR_REMOTE2 "git@github.com:myrepo/foobar" CACHE STRING "Path to the directory ... is located" )

find_package( Git )
