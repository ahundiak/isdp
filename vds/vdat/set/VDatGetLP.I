/* $Id: VDatGetLP.I,v 1.2 2001/01/19 15:55:21 ahundiak Exp $ */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdat/set/VDatGetLP.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatGetLP.I,v $
 *      Revision 1.2  2001/01/19 15:55:21  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/10  18:52:36  pinnacle
# ah
#
# Revision 1.1  1999/11/16  17:53:08  pinnacle
# 'replace VDatGetLgstPln.I with shorter name VDatGetLP.I.'
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/27/99	ylong		Created to get largest plane for 
 *					command	Drawing View From Plane
 *	03/07/00	ylong		TR179901164, added VDgetFavoriteSide() 
 *      01/19/01        ah              Removed duplicate function VDatPrintNodeInfo
 * -------------------------------------------------------------------*/

class implementation VDatBase;

#include "VDppl1.h"
#include "VDatProto.h"
#include "VDsa.h"
#include "VDobj.h"
#include "v_measmacros.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_drw.h"
#include "v_slcdef.h"
#include "v_pplslc.h"

/*
#define  DEBUG  1
#define  vdsDEBUG  1
*/
#include "v_dbgmacros.h"


static	IGRdouble	maxArea ;

from	GRvg		import	GRdetplane;

/* -----------------------------------------------
 * 19 Jan 2001 ah 
 * This function is now in vdmisc/VDatmacroi.I
 * Not sure why, perhaps a quick sp hack
 * But leave it there for now since it has other generic routines
 */
#if 0
/*
 * Print staging tree node info for testing
 */
IGRint	VDatPrintNodeInfo( TGRid *nodeID )
{
#ifdef DEBUG
	IGRchar		name[128], nodeType[128] ;

	VDatGetNodeName( nodeID, name );
	VDatGetNodeType( nodeID, nodeType );
	printf("node name: [%s], nodeType: [%s], ID: [%d, %d]\n",
		 name, nodeType, nodeID->objid, nodeID->osnum );
#endif

	return 1 ;
}
#endif

/*
 * Added for TR179901164
 * Call ppl function to get the side of the plate with more stiffeners
 */
IGRstat	VDgetFavoriteSide (	TGRobj_env	*plateOE, 	// in
				IGRint		*side ) 	// out
{
	IGRstat		retFlag = 0 ;

SetProc( GetFavoriteSide ); Begin

	vd$ppl_set_size(which_info	= INPUT_INFO, 
			size		= 1 );
	
	__DBGpr_obj("Input plateOE", plateOE->obj_id);
	vd$ppl_setarg_at_index( which_info	= INPUT_INFO,
				index		= 0,
				type		= VD_object,
				value		= plateOE );

	vd$ppl_exec(	file_name	= "PlateSide",
			func_name	= "main");

	vd$ppl_getarg_at_index(	which_info	= OUTPUT_INFO,
				index		= 0,
				value		= side );

	vd$ppl_free_args( which_info = INPUT_INFO );
	vd$ppl_free_args( which_info = OUTPUT_INFO );

	retFlag = 1 ;
wrapup:
End
	return retFlag ;
}


/*
 * Get plate area
 */
IGRint	VDatGetPlateArea(	TGRobj_env *plateOE,  // in
				IGRdouble *area )     // out
{
	IGRint		sts ;
	IGRlong		msg ;
	IGRchar		category[128] ;
	IGRpoint	pt1, pt2 ;
	TGRplane	plane ;


	plane.normal = pt1 ;
	plane.point  = pt2 ;
	sts = om$send ( msg = message GRvg.GRdetplane (
				&msg,
				&plateOE->mod_env.md_env.matrix_type,
				plateOE->mod_env.md_env.matrix,
				&plane ),
			senderid = NULL_OBJID,
			targetid = plateOE->obj_id.objid,
			targetos = plateOE->obj_id.osnum );
	if( !(sts = (sts&msg&1)) ) {
		goto wrapup ;
	}

	sts = vdsa$GetStruct(	objOE = plateOE,
				name  = "surface_area",
				dbl   = area);
	#ifdef DEBUG
	if( !(sts & 1) ) {
		__DBGpr_com("VDatGetPlateArea: vdsa$GetStruct failed");
	}
	printf("\tplateOE [%d, %d], area [%f]\n",
	 		plateOE->obj_id.objid, plateOE->obj_id.osnum, *area);
	#endif

wrapup:
	return sts ;
}


/*
 * Traverse subtree of nodeID to find out the largest plate (with max area)
 * recursively.
 */
IGRint	VDatGetLargestPlate( TGRid *nodeID, TGRobj_env *plateOE )
{
	TGRid		childID;
	TGRobj_env	objOE, tmpOE ;
	IGRint 		i, sts;
	IGRdouble	area ;

	if( nodeID->objid == NULL_OBJID )
	{
		return 1;
	}
	else if ( VDatIsBaseType( nodeID, VDAT_CLASSI_LEAF) )
	{
		VDatGetLeafObject( nodeID, &objOE );
		__DBGpr_obj("objOE", objOE.obj_id);
		sts = vdobj$IsAncestryValid(	objOE		= &objOE, 
						superClassName	= "VSplate");
		if( sts ) {
			sts = VDatGetPlateArea( &objOE, &area );
			if( sts && area > maxArea ) {
				maxArea = area ;
				*plateOE = objOE ;
			}
		}
		return 1;
	}

	VDatPrintNodeInfo( nodeID );

	// Get the children and recurse through them
	for(i = 0; VDatGetChildObject( nodeID, i, &childID); i++ ) 
	{
		#ifdef DEBUG
		printf("child[%d] ", i );
		VDatPrintNodeInfo( &childID );
		#endif

		VDatGetLargestPlate( &childID, plateOE );
	}

	return 1;

}


/*
 * Get drawing view plane with largest area 
 */
IGRint	VDatGetDrwViewPlane(	TGRid		*nodeID, 	// in
				TGRobj_env	*plateOE, 	// out
				TGRobj_env	*planeOE)	// out
{
	IGRint		retFlag = 0 ;
	IGRlong		sts ;
	IGRboolean	world = FALSE ;

	maxArea = 0. ;
	plateOE->obj_id.objid = NULL_OBJID ;

	retFlag = VDatGetLargestPlate( nodeID, plateOE ) ;

	if(!retFlag || plateOE->obj_id.objid == NULL_OBJID) {
		__DBGpr_com("Largest plate not found");
		goto wrapup ;
	}

	sts = vdobj$GetFoot(    objOE    = plateOE,
				footName = "plate:base",
				footOE   = planeOE) ;

	if( !(sts&1) || (planeOE->obj_id.objid == NULL_OBJID) ) {
		__DBGpr_com("Plane not found");
		goto wrapup ;
	}

	retFlag = 1 ;
wrapup:
	return retFlag ;
}

end implementation VDatBase ;
