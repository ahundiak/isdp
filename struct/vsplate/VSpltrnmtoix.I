/* $Id: VSpltrnmtoix.I,v 1.1.1.1 2001/01/04 21:10:53 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsplate/VSpltrnmtoix.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSpltrnmtoix.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/31  22:55:44  pinnacle
# (No comment)
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/28/00        Ming            TR179901209
 *
 ***************************************************************************/
class implementation VSplate ;

#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"

extern char		DIR_G_car_dir ;
/*----------------------------------------------------------------------------*/
method VStransNameToIPATH(	long		*msg ;
				char		*name ;
				VSixPath	*ipath ) {

	long			sts ;
	int			count,
				map[2] ;
	GRname			cmp1,
				cmp2,
				cmpNames[2] ;
	char			*sep ;		/* Ptr to dir separator	*/
	struct GRid		myOutput ;

	for( count = 0, sep = name ; *sep ; sep++ ) {
			if( *sep == DIR_G_car_dir ) count++ ;
	}

	/*
	 * If Name is in one or two parts: split it.
	 */
	switch( count ) {
	case 0 :
		/*
		 * Name in one part.
		 */
		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
					msg, cmp1, &myOutput, NULL, NULL ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "ACncpx.ACreturn_foot", wrapup ) ;

		ipath->ls[0] = 0 ;
		ipath->sz = 1 ;
		break ;

	case 1 :
		sep = strchr( name, DIR_G_car_dir ) ;
		*sep = '\0' ;
		strcpy( cmp1, name ) ;
		strcpy( cmp2, sep + 1 ) ;
		*sep = DIR_G_car_dir ;

		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
						msg, cmp1, &myOutput, NULL, NULL ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "ACncpx.ACreturn_foot", wrapup ) ;

		ipath->ls[0] = 0 ;


		sts = om$send(	msg	= message VSplate.VSgetFaceCount( msg, &count ),
				/* Added by Ming for TR179901209 */
				mode    = OM_e_wrt_message,
				targetid= my_id ) ;
		if( !( sts & 1 & *msg ) ) goto wrapup ;

		sts = om$send( msg	= message VSplate.VStopBottomMapping(
						msg, count, map, cmpNames ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSplate.VStopBottomMapping", wrapup ) ;

		     if( !strcmp( cmp2, cmpNames[0] ) ) ipath->ls[1] = map[0] ;
		else if( !strcmp( cmp2, cmpNames[1] ) ) ipath->ls[1] = map[1] ;
		else {
			/*
			 * Name is probably "$<n>".
			 */
			if( !VSreadGenericName( cmp2, &ipath->ls[1] ) ) {
				vs$inv_arg() ;
			}
		}
		ipath->sz = 2 ;

		break ;

	default	:
		sts = om$send(	msg	= message VSfeature.VStransNameToIPATH(
							msg, name, ipath ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}
	wrapup :
		return sts ;

} /* method VStransNameToIPATH */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

