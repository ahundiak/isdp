/* $Id*/

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsplate/VSspgetattr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSspgetattr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/02/19  20:33:58  pinnacle
# tr179900100
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/99  ah      TR179900100 Added check to make sure got shared data object
 ***************************************************************************/

class implementation VSsrcPlate ;

#include "EMSmsgdef.h"
#include "vsplatedef.h"
#include "vsplatmacros.h"
#include "vsdatadef.h"
#include "vsdata.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"

#define  vsDEBUGx 1
#define vdsDEBUGx 1

#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsshdatproto.h"

#include "VDobj.h"

from VSsharedData	import	VSgetData ;

extern VDclassid OPP_VSsharedData_class_id;

/*----------------------------------------------------------------------------*/
method GRgetattr(	long	*msg ;
			char	*attr ) {

	long		sts ;			/* OM return code	*/
	VSpartAttr	*part ;			/* Part attributes	*/
	VSplateAttr	*plate ;		/* Plate attributes	*/
	int		i,			/* Loop index		*/
			freeList ;		/* OK to free list ?	*/
	unsigned long	toGet ;			/* Attributes to get	*/
	struct GRid	myColl,			/* My data collection	*/
			userAttrId ;		/* Coll. of usr attr.	*/
	VSdataDesc	list[VS_K_plMAXDATA] ;	/* List of my data	*/

#define TO_GET( option ) ( ( toGet & (option) ) || ( toGet == VS_m_All ) )

	part	= (VSpartAttr	*) attr ;
	plate	= (VSplateAttr	*) part->specific ;
	toGet	= part->Iwant ;
	freeList= FALSE ;

#if vdsDEBUG 
	printf(">>> VSsrcPlate.GRgetattr()\n");
#endif
	
	*msg = MSFAIL ;

	/*
	 * Retrieve data.
	 */

	myColl.objid = NULL_OBJID;
	sts = om$send(msg = message 
		      VSfeature.VSfindCollection(
						 msg, VS_K_prPrvAttr, &myColl ),
		      targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSfindCollection", wrapup ) ;

	/* -----------------------
	 * Actually a possibility that the wrong object get's returned
         * Happens when a plate loses parents completely
	 */
	sts = vdobj$IsAncestryValid(objID = &myColl, 
				    superClassID = OPP_VSsharedData_class_id);
	if (!(sts & 1)) {
	  *msg = MSFAIL;
	  sts = OM_E_NOSUCHOBJ;
	  goto wrapup;
	}
	
#if vdsDEBUG
	vdobj$Print(objID = &myColl);
#endif

	for( i = 0 ; i < VS_K_plMAXDATA ; i++ ) list[i].index = i ;

	sts = om$send(	msg	= message VSsharedData.VSgetData(
						msg, VS_K_plMAXDATA, list ),
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

	sts = vs$fillPlateAttr(
		msg		= msg,
		options		= part->Iwant,
		thickness	= list[VS_K_plThickness		].value.d,
		cutOff		= list[VS_K_plCutOff		].value.d,
		offset		= list[VS_K_plOffset		].value.d,
		orientation	= list[VS_K_plOrientation	].value.i,
		matType		= list[VS_K_plMatType		].value.s,
		matGrade	= list[VS_K_plMatGrade		].value.s,
		partFam		= list[VS_K_plPartFam		].value.s,
		partNum		= list[VS_K_plPartNum		].value.s,
		usrNotes	= list[VS_K_plNotes		].value.s,
		mtoSrc		= list[VS_K_plMtoSrc		].value.s,
		mtoStk		= list[VS_K_plMtoStk		].value.s,
		mtoChgNo	= list[VS_K_plMtoChgNum		].value.i,
		FireProofing	= list[VS_K_plFpThck		].value.d,
		apprvStat	= list[VS_K_plApprSts		].value.s,
		constStat	= list[VS_K_plCnstSts		].value.s,
		mbrClass	= list[VS_K_plMbrClass		].value.i,
		mbrType		= list[VS_K_plMbrType		].value.i,
		usrAttrId	= &userAttrId,
		partAttr	= part,
		plateAttr	= plate ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( freeList ) VSfreeData( VS_K_plMAXDATA, list ) ;

#if vdsDEBUG 
	if (!(sts & *msg & 1)) printf("    FAILED!!!\n");
	printf("@@@ VSsrcPlate.GRgetattr()\n");
#endif
		return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSsrcPlate ;








