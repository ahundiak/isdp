/* $Id: VSjngetcolid.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjngetcolid.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjngetcolid.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1998/01/02  11:57:44  pinnacle
# Created: vsjoint/VSjngetcolid.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "nddef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern	OMuword	OPP_ACrg_collect_class_id,
		OPP_VSsharedData_class_id ;
/*----------------------------------------------------------------------------*/
method VSgetCollectionId( long *msg ; char *name ; struct GRid *coll ) {

	long		sts ;
	int		ACrc ;
	unsigned long	type ;
	int		i, pCount = 0;
	struct GRid	*gKids = NULL ;

	SetProc( VSjoint_VSgetCollectionId ); Begin

	coll->objid = NULL_OBJID ;

	*msg = MSFAIL ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	
							ND_ROOT | ND_IN_BUF,
							NULL,
							0,
							&gKids,
							0,
							OM_K_MAXINT,
							&pCount ),
			targetid = my_id );
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	if(! pCount ) {
		*msg = MSFAIL ;
		sts = OM_W_ABORT ;
		goto wrapup ;
	}
	__DBGpr_int(" Count of Parentts", pCount );

	sts = OM_W_ABORT ;

	for( i = 0 ; i< pCount ; i++ ) {

		if( strcmp( name, VS_K_prPrvAttr ) == 0 ) {
			if( vs$is_ancestry_valid(	
				object	= &gKids[i],
				classid	= OPP_VSsharedData_class_id ) ) {

				coll->objid = gKids[i].objid ;
				coll->osnum = gKids[i].osnum ;
				*msg = MSSUCC ;
				sts = OM_S_SUCCESS ;
			}
		} else if( strcmp( name, VS_K_prUsrAttr ) == 0 ) {
			if( vs$is_ancestry_valid(
				object  = &gKids[i],
				classid = OPP_ACrg_collect_class_id ) ) {

				coll->objid = gKids[i].objid ;
				coll->osnum = gKids[i].osnum ;
				*msg = MSSUCC ;
				sts = OM_S_SUCCESS ;
			}
		}
	}

	wrapup :
		End 
		return sts ;

} /* method VSfindCollection */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

