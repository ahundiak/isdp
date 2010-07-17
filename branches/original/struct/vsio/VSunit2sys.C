/* $Id: VSunit2sys.C,v 1.2 2001/02/17 19:40:02 build Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsio/VSunit2sys.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSunit2sys.C,v $
 *      Revision 1.2  2001/02/17 19:40:02  build
 *      Included VDobj.h file to resolve some compilation errors.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.2  1996/01/31  08:04:28  pinnacle
 * Replaced: vsio/VSunit2sys.C for:  by svkadamb for struct
 *

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT

	VSunit2sys
	----------
Abstract
	Converts a united value to a system value.
Arguments
	OUT	long	*msg		completion code
	IN	char	*table		UOM table
	IN	char	*unit		unit to convert
	OUT	double	*p_value	system value to convert
*/ 
#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "UOMdef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "msdef.h"		/* For MS...		*/
#include "griodef.h"
#include "griomacros.h"
#include "VDobj.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
int VSunit2sys( msg, unit, table, p_value )

long	*msg	;	/* OUT : completion code		*/
char	*table	;	/* IN  : UOM table			*/
char	*unit	;	/* IN  : unit to convert		*/
double	*p_value; {	/* OUT : system value 			*/

	/*
	 * Since the unit subsystem won't parse "3 ft 2 in" or "2 cm 3 mm"
	 * but only "3 ft + 2 in" and "2 cm 3 mm", we have to front-end it to
	 * make it user-friendly.
	 * We suppose there won't be more that 5 units in a row (such as
	 * 1 km 3 hm 4 dam 7 cm 2 mm) which is already *a lot* !).
	 */
#define MAX 5
	/*
	 * For safety, only process reasonable-size character strings...
	 */
	if( strlen( unit ) < UOM_K_MAX_LEN ) {
	  char   u[MAX][UOM_K_MAX_LEN] ;
	  char	 buffer[UOM_K_MAX_LEN+MAX*3] ;
	  double v[MAX] ;
	  int    i ;
	  int	 l ;

	  for( i = 0 ; i < MAX ; i++ ) {
	    u[i][0] = '\0' ; v[i] = MAXDOUBLE ;
	  }
	  sscanf( unit, "%lf%s%lf%s%lf%s%lf%s%lf%s",
		   &v[0], &u[0][0],
		   &v[1], &u[1][0],
		   &v[2], &u[2][0],
		   &v[3], &u[3][0],
		   &v[4], &u[4][0] ) ;
	  for( i = l = 0 ; i < MAX ; i++ ) {
	     if( MAXDOUBLE == v[i] ) break ;
	     if( i != MAX-1 && MAXDOUBLE != v[i+1] )
	           l += sprintf( buffer + l, "%g %s + ", v[i], u[i] ) ;
	     else  l += sprintf( buffer + l, "%g %s"   , v[i], u[i] ) ;
	  } 
	  unit = buffer ;
        }

	co$expreval(	msg		= msg,
			scale_flag	= GRIO_NO_SCALE,
			expression	= unit,
			unit_type	= table,
			result		= p_value ) ;

	return *msg & 1 ;
		
} /* VSunit2sys */
/*----------------------------------------------------------------------------*/

