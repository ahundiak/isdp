
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
*/


#if CHECK_RETURN_CODES

#include "stdio.h"
#include "bserr.h"

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

#   define OM_ERRCHK( sts, string )

#   define MSG_ERRCHK( msg, string )

#   define BS_ERRCHK( rc, string  )

#   define BS_STSCHK( sts, string )

#endif

/* defines for EMS plotting interpreter */

/* ------- nurb curve flags ------- */
#define CV_PERIODIC_M		0x0001
#define CV_NON_UNIFORM_M	0x0002
#define CV_RATIONAL_M		0x0004
#define CV_PLANAR_M		0x0008
#define CV_PHY_CLOSED_M		0x0010

/* ------- nurb surface flags ------- */
#define SF_U_PERIODIC_M		0x0001
#define SF_V_PERIODIC_M		0x0002
#define SF_U_NON_UNIFORM_M	0x0004
#define SF_V_NON_UNIFORM_M	0x0008
#define SF_RATIONAL_M		0x0010
#define SF_PLANAR_M		0x0020
#define SF_U_CLOSED_M		0x0040
#define SF_V_CLOSED_M		0x0080
#define SF_ORIENTATION_M	0x0100
#define SF_SOLID_HOLE_M		0x0200

/* ------- useful macros ------- */
#define _str_eq(s1,s2) (!strcmp(s1,s2))
#define _str_lt(s1,s2) (strcmp(s1,s2)<0)
#define _str_gt(s1,s2) (strcmp(s1,s2)>0)
#define return_bad(status) if(!((status)&1))return(status)
#define if_bad(status)	   if(!((status)&1))

/* ------- processing mode flags ----- */
#define	PM_PRE_WIREFRAME	0
#define	PM_ZBUFFERING		1
#define	PM_POST_WIREFRAME	2

/* ------- rendering mode flags ------- */
#define	RM_WIREFRAME			0
#define	RM_ZBUFFERED_SMOOTH		1
#define	RM_ZBUFFERED_CONSTANT		2
#define	RM_ZBUFFERED_RASTER_EDGES	3
#define	RM_ZBUFFERED_FILLED_RASETER	4
#define	RM_ZBUFFERED_AREA_FILL		5

#define	HS14	0
