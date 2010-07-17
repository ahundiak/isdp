/*
	I/STRUCT
*/ 
class implementation VSsrcBeam ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsdatadef.h"
#include "vsdata.h"
#include "vsdatamacros.h"
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
	VSbeamAttr	*beam ;			/* Beam attributes	*/
	unsigned long	toGet ;			/* Attributes to get	*/
	struct GRid	myColl,			/* My data collection	*/
			userAttrId ;		/* Coll. of usr attr.	*/
	VSdataDesc	list[VS_K_bmMAXDATA] ;	/* List of my data	*/
	enum VScardinal_point
			cardPt ;
	enum VSsymmetry	sym ;

#define TO_GET( option ) ( ( toGet & (option) ) || ( toGet == VS_m_All ) )

	part		= (VSpartAttr *) attr ;
	beam		= (VSbeamAttr *) part->specific ;
	toGet		= part->Iwant ;
	freeList	= FALSE ;

	/*
	 * Retrieve data.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
						msg, VS_K_prPrvAttr, &myColl ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSfindCollection", wrapup ) ;

	for( i = 0 ; i < VS_K_bmMAXDATA ; i++ ) list[i].index = i ;

	sts = om$send(	msg	= message VSsharedData.VSgetData(
						msg, VS_K_bmMAXDATA, list ),
			targetid= myColl.objid,
			targetos= myColl.osnum ) ;
	__CheckRC( sts, *msg, "VSsharedData.VSgetData", wrapup ) ;

	freeList = TRUE ;

	if( TO_GET( VS_m_UsrAttr ) ) {
		sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
							msg, &userAttrId ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetUserAttributes", wrapup );
	}

	cardPt	= (enum VScardinal_point) list[VS_K_bmCardPnt ].value.i ;
	sym	= (enum VSsymmetry      ) list[VS_K_bmSymmetry].value.i ;

	sts = vs$fillBeamAttr(
		msg		= msg,
		options		= part->Iwant,
		xOffset		= list[VS_K_bmXOffset	].value.d,
		yOffset		= list[VS_K_bmYOffset	].value.d,
		RotAngle	= list[VS_K_bmRotAngle	].value.d,
		FireProofing	= list[VS_K_bmFpThck	].value.d,
		cardPnt		= cardPt,
		symmetry	= sym,
		matType		= list[VS_K_bmMatType	].value.s,
		matGrade	= list[VS_K_bmMatGrade	].value.s,
		partFam		= list[VS_K_bmPartFam	].value.s,
		partNum		= list[VS_K_bmPartNum	].value.s,
		usrNotes	= list[VS_K_bmNotes	].value.s,
		mtoSrc		= list[VS_K_bmMtoSrc	].value.s,
		mtoStk		= list[VS_K_bmMtoStk	].value.s,
		mtoChgNo	= list[VS_K_bmMtoChgNum	].value.i,
		apprvStat	= list[VS_K_bmApprSts	].value.s,
		constStat	= list[VS_K_bmCnstSts	].value.s,
		mbrClass	= list[VS_K_bmMbrClass	].value.i,
		mbrType		= list[VS_K_bmMbrType	].value.i,
		usrAttrId	= &userAttrId,
		partAttr	= part,
		beamAttr	= beam ) ;

	wrapup :
		if( freeList ) VSfreeData( VS_K_bmMAXDATA, list ) ;
		return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;
