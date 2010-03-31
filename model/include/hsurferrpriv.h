
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsurferrpriv_include
#define hsurferrpriv_include 1

/*
DESCRIPTION
	Macros for checking return codes from OM and IGE

	If you want to have the return codes tested, you must define
	CHECK_RETURN_CODES to be non-zero before this file is included.
*/


#if CHECK_RETURN_CODES

#include "stdio.h"

#   define OM_ERRCHK( status, string )			           \
	 						           \
  	   if ( ! (1 & status) )			   	   \
	      {						           \
	      fprintf( stderr, "%s, sts = %d\n", string, status ); \
	      som_report_error( sts = status );                     \
	      }


#   define MSG_ERRCHK( msg, string )			           \
							           \
	   if ( ! (1 & msg) )				           \
	      {						           \
	      fprintf( stderr, "%s, msg = %d\n", string, msg );    \
	      }


#else

#   define OM_ERRCHK( sts, string )

#   define MSG_ERRCHK( msg, string )

#endif
#endif
