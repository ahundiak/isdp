/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vssectiondef.h"

extern char	DIR_G_car_dir ;
/*----------------------------------------------------------------------------*/
method VStransNameToIPATH(	long		*msg ;
				char		*name ;
				VSixPath	*ipath ) {

	long		sts ;		/* OM return code		*/
	int		i,
			j ;
	VSdspRep	myRep ;		/* My display representation	*/
	char		*nl[4],		/* Pointers to names in path	*/
			*n ;
	GRname		Name ;		/* For "$n" name		*/
	
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	/*
	 * If beam is not in external representation, name is in the form:
	 * 			"<name1>:<name2>:<name3>"
	 * at the most.
	 */
	nl[0] = n = strcpy( Name, name ) ;
	j = 0 ;
	for( i = 1 ; i < 4 ; i++ ) {
		nl[i] = strchr( n, DIR_G_car_dir ) ;
		if( nl[i] ) {
			n = nl[i] + 1 ; *nl[i] = '\0' ; j++ ;
			nl[i]++ ;
		}
	}

	if( j > 2 ) { goto ANCESTOR ; }
	ipath->sz = j + 1 ;
	
	for( i = 0 ; i < ipath->sz ; i++ ) {

	switch( i ) {

	case 0 :
		if( !strcmp( nl[0], VS_K_bmGrCmpName ) ) {
			ipath->ls[0] = 0 ;
		} else {
    			goto ANCESTOR ;
    		}
		break ;
	
	case 1 :	
		if( !strcmp( nl[1], VS_K_bmBody ) ) 
		     	ipath->ls[1] = 0 ;
		else if( !strcmp( nl[1], VS_K_bmBeginCap	) )
			ipath->ls[1] = 1 ;
		else if( !strcmp( nl[1], VS_K_bmEndCap	) )
			ipath->ls[1] = 2 ;
		else {
			goto ANCESTOR ;
		}
		break ;

	case 2 :
		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= my_id ) ;

		sts = om$send(	msg	= message VSbeam.VSfaceNameToIndex(
					msg, myRep, nl[2], ipath->ls + 2 ),
				targetid= my_id ) ;
		/*
		 * The above message send will fail if the face name is
		 * wrong or the beam does not have the face because it is
		 * not in the ad-hoc representation.
		 */
		if( !( sts & 1 & *msg ) ) goto wrapup ;

		break ;

	default	:
	ANCESTOR:
		sts = om$send(	msg	= message VSfeature.VStransNameToIPATH(
						msg, name, ipath ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} /* switch */
	} /* for */

	wrapup :
		return sts ;

} /* method VStransNameToIPATH */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
