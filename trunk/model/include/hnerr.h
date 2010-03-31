
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/



/*
DESCRIPTION
	Macros for checking return codes.  If you want return codes to be tested,
	define CHECK_RETURN_CODES as 1.  If you do not want return codes to be tested,
	define CHECK_RETURN_CODES as 0. 
	
HISTORY
	S.P. Rogers  01/05/87  Creation Date
	07/22/88	KMJ	add DI_ERRCHK
*/


#if CHECK_RETURN_CODES

#include "stdio.h"
#include "bserr.h"

#   define DI_ERRCHK( status, string )			           \
	 						           \
  	   if ( ! (1 & status) )			   	   \
	      {						           \
	      di$report_error( sts = status, comment=string);	   \
	      }

#   define OM_ERRCHK( status, string )			           \
	 						           \
  	   if ( ! (1 & status) )			   	   \
	      {						           \
	      fprintf( stderr, "%s, sts = %d\n", string, status ); \
	      om$report_error( sts = status );                     \
	      }


#   define MSG_ERRCHK( msg, string )			        \
							        \
	   if ( ! (1 & msg) )				        \
	      {						        \
	      fprintf( stderr, "%s, msg = %d\n", string, msg ); \
	      }


#   define BS_ERRCHK( rc, string )                            \
	                                                      \
	   if ( rc != BSSUCC )                                \
	      {                                               \
	      fprintf( stderr, "%s, rc = %d\n", string, rc ); \
	      }


#   define BS_STSCHK( sts, string )                              \
	                                                         \
	   if ( ! sts )                                          \
	      {                                                  \
	      fprintf( stderr, "%s, sts = %d\n", string, sts );  \
	      }

#else

#   define DI_ERRCHK( status, string )			           \

#   define OM_ERRCHK( sts, string )

#   define MSG_ERRCHK( msg, string )

#   define BS_ERRCHK( rc, string  )

#   define BS_STSCHK( sts, string )

#endif
