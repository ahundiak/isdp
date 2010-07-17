/* $Id: VSbscnstfeet.I,v 1.1.1.1 2001/01/04 21:10:21 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmsupp/VSbscnstfeet.I
 *
 * Description: Gets top or bottom of plate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbscnstfeet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:21  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/09  09:16:54  pinnacle
# Replaced: vsbmsupp/VSbscnstfeet.I for:  by svkadamb for struct
#
# Revision 1.2  1998/02/20  20:26:00  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 ***************************************************************************/

/* CR179800676
 * To implement this tr I modified the VSbeamAxis object to use some of it's
 * spare attrFlag bits.  While VSbmSupp does not subclass from VSbeamAxis, it
 * appears to share manny of the same features.
 *
 * I replaced VS_K_baExtendAxis in the axis object because I did not like the
 * mask test.  It is still used here even though I don't think this class allows
 * setting this bit.
 *
 * I am going to rename it and add it to vsbmsuppdef.h file
 * I will have to see if I need to add the additional attributes in this object as well.
 */

class implementation VSbeamSupp ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vssplitdef.h"
//#include "vsbmaxisdef.h" // CR179800676 Decoupled VSbeamAxis
#include "vsbmaxisdef.h"
#include "vsbmsuppdef.h"
#include "vsplatedef.h"
#include "vsiomacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
#include "vsvirtualinf.h"
#include "bsdotp.h"

/*
 * External functions
 */
extern long	VSplaceSkinningSurface() ;
extern long	VStxtExpValue() ;

from ACpretend	import	ACfind_parent;
from VSbeamAxis	import	VSgetPlateSide ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					count ;
			struct GRid	list[] ;
			struct GRmd_env *MyEnv ;
			int		*feetCount ;
			struct GRid	*feetList ) {

	long			sts ;		/* OM return code.	    */
	struct GRvg_construct	cst ;		/* My construction list.    */
	struct GRobj_env	templates[5],	/* 0: plate,		    */
						/* 1: curve or surface,     */
						/* 2: start surface limit   */
						/*    or end surface limit  */
						/*    if no start surface.  */
						/* 3: end surface limit.    */
				SideObj;	/* Side to place axis.	    */

	struct GRid		myGrid ; 	/* My grid.		    */
	char                    *sidename ;     /* Name of side of plate.   */
	struct GRsymbology	mySymb ;	/* My symbology.	    */
	struct GRobj_env	skSrf, plate ;
	int			i, twsCnt=0 , ACcount, flag ;
	struct VStws_info	*twsInfo = NULL ;
	long			rc ;
	double			xsAng ;
	char			refType[80] ;
	struct GRid		ACpretend ;
	struct GRid		beamAxis ;

	if( !count ) { *msg = MSINARG ; return OM_W_ABORT ; }
	/*
	 * NOTE: the AC system has initialized all the "feetList[k].objid"
	 * to NULL_OBJID.
	 */
	feetList[0].objid = NULL_OBJID ;

	myGrid.objid = my_id ; myGrid.osnum = OM_Gw_current_OS ;

	vs$dotsInStsFld( dots = 0 ) ;

	/*
	 * Get the symbology and Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= MyEnv,
				Display 	= &mySymb.display_attr,
				Level		= mySymb.level,
				Properties 	= 0, 
				Cnst_list	= cst ) ;

	/*
	 * Get graphics parents.
	 */
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, count, list, templates ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	__DBGpr_obj( " First template ", list[0] );

	vs$dotsInStsFld() ;

	/*
	 * Get the plate from the beam axis
	 */
	sts = om$send( msg = message ACpretend.ACfind_parent(
						&beamAxis,
						NULL,
						NULL ),
			targetid = list[0].objid,
			targetos = list[0].osnum );
	__CheckRC( sts, *msg, "ACpretend.ACfind_parent", wrapup ) ;
	__DBGpr_obj( " First Parent", beamAxis );

	sts = om$send( msg = message NDnode.NDget_objects(
						ND_ROOT,
						&ACpretend,
						1,
						NULL,
						0,
						0,
						&ACcount ),
			targetid = beamAxis.objid,
			targetos = beamAxis.osnum );
	__CheckRC( sts, 1, "NDnode.NDget_object", wrapup ) ;


	/*
	 * Parent plate may in fact be a pretend or an image of a plate.
	 * In any case get tranformation matrix and virtual id if applicable.
	 */
	sts = VSgetVirtualInfo( msg,
				&ACpretend,
				&plate.mod_env,
				&plate._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
	__DBGpr_obj( " plate obj", plate._grid );

	/*
	 * Retrieve side of plate, support of this axis.
	if( (me->flagAttr & ~VS_K_bsExtendAxis) == VS_K_bsOnTopOfPlate ) 
		sidename = VS_K_plTopSfPathABS ;
	else	sidename = VS_K_plBotSfPathABS ;
	 */
	sts = om$send(msg = message VSbeamAxis.VSgetPlateSide(msg,&flag),
			       targetid = beamAxis.objid,
			       targetos = beamAxis.osnum);
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetPlateSide", wrapup ) ;


	if(flag == VS_K_baOnTopOfPlate ) sidename = VS_K_plTopSfPathABS ;
	else                             sidename = VS_K_plBotSfPathABS ;

	sts = om$send( msg = message NDmacro.ACreturn_foot(
						msg,
						sidename,
						&SideObj.obj_id,
						&templates[0]._matrix_type,
						templates[0]._matrix ),
		       targetid = plate._objid,
		       targetos = plate._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	SideObj.mod_env = templates[0].mod_env ;
	__DBGpr_obj(" Plate side", SideObj._grid );
	/*
	 * Fill the twist information
	 */
	twsCnt = (count - 2 )/3 + 2 ;

	if(!( twsInfo = _MALLOC( twsCnt, struct VStws_info ) ) ) 
		vs$mem_fail();
	/*
	 * Intilaise the position objects to NULL  OBJID 
	 */
	for(i=0; i <twsCnt ; i++ ) {
		twsInfo[i].position._objid = NULL_OBJID ;
	}
	/*
	 * get the parent #1 which is an expression with twist info
	 */
	sts = VStxtExpValue( list[1].objid, list[1].osnum,
				refType ) ;
	__CheckRC( sts, 1, "VSexpValue", wrapup ) ;

	sscanf(refType,"%c|%lf|%c|%lf",&twsInfo[0].refType,&twsInfo[0].angle,
					&twsInfo[1].refType,&twsInfo[1].angle );
	
	/*
	 * get the skinned surface with the twist info
	 */
	sts = VSplaceSkinningSurface(	msg,
					templates[0],
					SideObj,
					&cst,
					twsCnt,
					twsInfo,
					&skSrf );
	__CheckRC(sts, *msg, "VSplaceSkinningSurface", wrapup );

	/* 
	 * make sure that the normal of the surface is pointing in the same
	 * direction of that the face of the plate object on which the 
	 * stiffener is placed
	 */
	{
		IGRvector	nmOfSupp, nmOfSide ;
		double		dp ;
		vs$get_normal (	msg	= msg,
				sfId	= &SideObj._grid,
				sfEnv	= &SideObj.mod_env,
				normal	= nmOfSide ) ;
		__CheckRC( 1, *msg, "vs$get_normal", wrapup );

		__DBGpr_vec(" Normal Of Side ", nmOfSide );

		vs$get_normal (	msg	= msg,
				sfId	= &skSrf._grid,
				sfEnv	= MyEnv,
				normal	= nmOfSupp ) ;
		__CheckRC( 1, *msg, "vs$get_normal", wrapup );

		__DBGpr_vec( "Normal Of Support  ", nmOfSupp );

		dp = BSdotp( &rc, nmOfSupp, nmOfSide) ;
		if( dp < 0. ) {
			vs$reverse_sf_orientation( msg	     = msg,
						   surfaceId = &skSrf._grid,
						   ignRevFlag= TRUE ) ;
		}
	}

	feetList[0].objid = skSrf._objid ;
	feetList[0].osnum = skSrf._osnum ;

	*feetCount = 1 ;

	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :
		vs$dotsInStsFld( dots = clear ) ;
		_FREE( twsInfo ) ;

		if( !( sts & 1 & *msg ) ) {
			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
			vs$bulk_delete( count	= 1,
					grids 	= &skSrf._grid,
					theEnv	= MyEnv );
		}
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSbeamSupp ;
