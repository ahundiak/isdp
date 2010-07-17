/* $Id: VSslsleep.I,v 1.1.1.1 2001/01/04 21:10:58 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsselector/VSslsleep.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSslsleep.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1997/02/04  18:16:56  pinnacle
# Replaced: vsselector/VSslsleep.I for:  by s241_int for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/04/97	adz		do not delele selector when owned.
 ***************************************************************************/

class implementation VSselector ;

#include "nddef.h"
#include "EMSmsgdef.h"
#include "asbox.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method	NDsleep( struct GRmd_env *myEnv ) {

	int	nbParents	= 0 ,
		nbChildren	= 0 ,
		stillHere	= TRUE ;
	OMuint	nbOwned		= 0 ;
	long	sts ;

	SetProc( VSselector_NDsleep ); Begin

	sts = om$send(	msg	= message NDnode.NDget_objects(
					ND_ROOT, NULL, 0, NULL, 0, OM_K_MAXINT,
					&nbParents ),
			targetid= my_id ) ;

	if( !nbParents ) {

	  sts =
	  om$send(  msg	= message NDnode.NDget_objects(
				ND_CHILDREN, NULL, 0, NULL, 0, OM_K_MAXINT,
				&nbChildren ),
		    targetid= my_id ) ;

	  if( !nbChildren ) {

		/*
		 * Check if you are owned.
		 */

		OM_S_OBJECT_LINKAGE	as_link;

		sts =
		om$get_channel_objects(
			osnum		= OM_Gw_current_OS,
                        objid		= my_id,
                        p_chanselect	= &AS_to_owner,
			list		= &as_link,
			size		= 1,
			count		= &nbOwned);

		if( !(sts&1) || nbOwned == 0 ){

			GRname	myName ;
			long	msg ;

			*myName = '\0' ;
			sts = om$send(	msg	= message GRgraphics.GRgetname(
								&msg, myName ),
					targetid= my_id ) ;
			if( !*myName ) {

				__DBGpr_com(" Delete the object ");

				sts = om$send(
					msg	= message NDnode.NDdelete(
									myEnv ),
					targetid= my_id ) ;

				stillHere = FALSE ;
			}
		}
	  }
	}

	if( stillHere ) {
		sts = om$send(	msg	= message ACncpx.NDsleep( myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	End 

	return sts ;

} /* method NDsleep */
/*----------------------------------------------------------------------------*/

end implementation VSselector ;

