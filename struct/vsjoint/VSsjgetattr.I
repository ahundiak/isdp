/* $Id: VSsjgetattr.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSsjgetattr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSsjgetattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/23  20:27:30  pinnacle
# Replaced: vsjoint/VSsjgetattr.I for:  by impd for struct
#
# Revision 1.3  1997/12/19  04:01:58  pinnacle
# Replaced: vsjoint/VSsjgetattr.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  13:05:30  pinnacle
# Replaced: vsjoint/VSsjgetattr.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSsrcJoint ;

#include <string.h>
#include "EMSmsgdef.h"
#include "vsdatadef.h"
#include "vsdata.h"
#include "vsdatamacros.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsshdatproto.h"

from VSsharedData	import VSgetData ;
/*----------------------------------------------------------------------------*/
method GRgetattr(	long	*msg ;
			char	*attr ) {

	long		sts ;			/* OM return code	*/
	int		i,			/* Loop-on-data index	*/
			freeList ;		/* OK to free list ?	*/
	VSpartAttr	*part ;			/* Part attributes	*/
	VSjointAttr	*joint ;		/* Joint attributes	*/
	VSweldAttr	wa ;			/* Weld attributes	*/
	VSaddWldAttr	addWa ;			/* Weld attributes	*/
	unsigned long	toGet ;			/* Attributes to get	*/
	struct GRid	myColl,			/* My data collection	*/
			userAttrId ;		/* Coll. of usr attr.	*/
	VSdataDesc	list[VS_K_jnMAXDATA] ;	/* List of my data	*/

#define TO_GET( option ) ( ( toGet & (option) ) || ( toGet == VS_m_All ) )

	SetProc( VSsrcJoint_GRgetattr ) ; Begin ; __DBGpr_me() ;

	part		= (VSpartAttr *) attr ;
	joint		= (VSjointAttr *) part->specific ;
	toGet		= part->Iwant ;
	freeList	= FALSE ;
	/*
	 * Retrieve private collection of data.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
						msg, VS_K_prPrvAttr, &myColl ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSfindCollection", wrapup ) ;

	/*
	 * Init `get' list.
	 */
	for( i = 0 ; i < VS_K_jnMAXDATA ; i++ ) list[i].index = i ;

	sts = om$send(	msg	= message VSsharedData.VSgetData(
						msg, VS_K_jnMAXDATA, list ),
			targetid= myColl.objid,
			targetos= myColl.osnum ) ;
	__CheckRC( sts, *msg, "VSsharedData.VSgetData", wrapup ) ;

	freeList = TRUE ;

	if( TO_GET( VS_m_UsrAttr ) ) {
		sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
							msg, &userAttrId ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetUserAttributes", wrapup );
		__DBGpr_obj( "Found user attr.", userAttrId ) ;
		part->usrAttr = userAttrId ;
	}

	if( TO_GET( VS_m_AddWeldAttr ) ) {
		memcpy( &addWa,
			&list[VS_K_jnAddWeldAttr].value.i,
			sizeof( int ) ) ;
		__DBGpr_int( "Found weld position", addWa.position ) ;
	}

	if( TO_GET( VS_m_WeldAttr ) ) {
		memcpy( &wa,
			&list[VS_K_jnWeldAttr].value.i,
			sizeof( int ) ) ;
		__DBGpr_int( "Found weld code", wa.code ) ;
	}

	vs$fillJointAttr(
		msg		= msg,
		options		= part->Iwant,
		allowance	= list[VS_K_jnAllowance		].value.d,
		grooveAngle	= list[VS_K_jnGrooveAngle	].value.d,
		pitch		= list[VS_K_jnPitch		].value.d,
		incrLength	= list[VS_K_jnIncrLength	].value.d,
		weldAttr	= &wa,
		addWldAttr	= &addWa,
		size		= list[VS_K_jnSize		].value.d,
		shrinkage	= list[VS_K_jnShrinkage		].value.d,
		usrSymbol	= list[VS_K_jnUsrSymbol		].value.s,
		usrAttrId	= &userAttrId,
		partAttr	= part,
		jointAttr	= joint ) ;
	
	wrapup :
		if( freeList ) VSfreeData( VS_K_jnMAXDATA, list ) ;
		End
		return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSsrcJoint ;
