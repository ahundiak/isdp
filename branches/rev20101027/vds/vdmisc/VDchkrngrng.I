/* $Id: VDchkrngrng.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDchkrngrng.I
 *
 * Description:
 *		This function is used to check, using the range of the
 *		objects, if an object is inside or outside the range of
 *		the solid. The VDsolid_surf_rln returns VD_OVERLAP,
 *		whenever intersection occurs. What need to check here,
 *		that the overlapping is inside and not outside the 
 *		control object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDchkrngrng.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/07/06  20:37:56  pinnacle
# Replaced: vdmisc/VDchkrngrng.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/05  13:18:26  pinnacle
# Replaced: vdmisc/VDchkrngrng.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/30/95	adz		creation date
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "exdef.h"
#include "exmacros.h"
#include "VDvolelem.h"
#include "vd_ve.h"
#include "v_drw.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsxtractpar.h"

from	EMSsubbs	import	EMreduce_range;

extern	GRclassid	OPP_EMSsolid_class_id ;

/*----------------------------------------------------------------------------*/
long VD_reduceObjRange(		msg,
				elmId,
				elmEnv )

long			*msg ;
struct	GRid		*elmId ;
struct	GRmd_env	*elmEnv ;
{

	/*
	 * Reduce the object range of the object when possible.
	 * An new object will be generated and replaced the existing.
	 */
	int			sts = OM_S_SUCCESS ;
	struct	GRid		redId ;

	redId.objid = NULL_OBJID ;

	sts =
	om$send(msg = message EMSsubbs.EMreduce_range(
						msg,
						elmEnv,
						&redId.objid,
						0 ),
	        senderid = elmId->objid,
	        targetid = elmId->objid,
	        targetos = elmId->osnum ) ;
	if( sts & *msg & 1 ){
		if( om$is_objid_valid(
			objid	= redId.objid,
			osnum	= elmId->osnum ) == OM_S_SUCCESS ){
			elmId->objid = redId.objid ;
		}
	}

	return sts ;
}

/*----------------------------------------------------------------------------*/
long VD_checkRangeInsideRange(	msg,
				border,
				range,
				elmId,
				elmEnv,
				reduce )

long			*msg ;
struct	GRobj_env	*border ;
GRrange			range ;
struct	GRid		*elmId ;
struct	GRmd_env	*elmEnv ;
IGRboolean		reduce ;
{
	/*
	 * Given an object (border). and check if the given check object
	 * (elmId, elmEnv) are inside this object borders. When this is 
	 * valid return TRUE, otherwise FALSE.
	 */
	int			sts = OM_S_SUCCESS ;
	int			i,	/* Loop index.			      */
				relShip;/* Relation ship between two ranges.  */
	IGRchar			relation; /* Border object relation           */
	GRrange 		elmRng, /* Range of object.		      */
				brdRng ;/* Range of virtual element.	      */
	short			world ; /* Compute range in world coordinate. */

	/*
	 * The construction to be drawn is also on the list of located
	 * elements. So, swap the last solid / surface with the foot
	 * to project.
	 */

	SetProc( VD_checkRangeInsideRange ); Begin

	*msg	= MSSUCC ;

	relShip	= FALSE ;	/* Error or outside range. */

#ifdef	vdsDEBUG
	VD_ShowObj( & border->_grid );
	VD_ShowObj( elmId );
#endif

	if( range ){
	  for( i=0 ; i<6 ; i++ )	brdRng[i] = range[i] ;
	}
	else{
	  world = TRUE ;
	  sts = om$send( msg	= message GRgraphics.GRgetrang(
						       msg,
						       &border->_matrix_type,
						       border->_matrix,
						       &world,
						       brdRng ),
		       senderid = border->_objid,
		       targetid = border->_objid,
		       targetos = border->_osnum ) ;
	  __CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
	}

	__DBGpr_vec( "Range of border min", brdRng    ) ;
	__DBGpr_vec( "Range of border max", brdRng +3 ) ;

	/*
	 * Solids can give invalid range values. We assume they are oke
	 * and return TRUE ;
	 */
        if( vd_$is_ancestry_valid(
                        object  = elmId,
                        classid = OPP_EMSsolid_class_id )){

		relShip = TRUE ;
		return	relShip ;
	}
								
	/*
	 * Get range of checking object.
	 */
	if( reduce ){
		/*
		 * reduce the range of the object.
		 */
		sts =
		VD_reduceObjRange( msg, elmId, elmEnv );
	}

	world = TRUE ;
	sts = om$send( msg	= message GRgraphics.GRgetrang(
						       msg,
						       &elmEnv->_MATRIX_TYPE,
						       elmEnv->_MATRIX,
						       &world,
						       elmRng ),
		       senderid = elmId->objid,
		       targetid = elmId->objid,
		       targetos = elmId->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Range of object min", elmRng    ) ;
	__DBGpr_vec( "Range of object max", elmRng +3 ) ;

	/*
	 * Extend the range of the border to avoid coincidence.
	 * The reduce range functionality reduce the range of the object to
	 * an higher value. Therefor, the range of the solid need to be extended
	 * with more than an tolerance. The reduce range result is rounding
	 * of the surface.
	 */
	for( i=0; i<3 ; i++ ){
		if( elmRng[i]   - brdRng[i]    < -2.0 )	goto wrapup;
		if( elmRng[i+3] - brdRng[i+3]  >  2.0 )	goto wrapup;
	}

	relShip = TRUE ;

	wrapup:

		if( ! relShip ){
			/*
			 * check on intersection.
			 */
			__DBGpr_com(" Check if it's really outside ");

			relation = VD_UNKNOWN ;
			VDsolid_surf_rln(	msg,
						& border->obj_id,
						& border->mod_env,
						elmId,
						elmEnv,
						& relation );

			if( (*msg&1) && relation == VD_OUTSIDE ){
				__DBGpr_com(" Object Outside - continue ");
				relShip = FALSE ;
			}
			else{
				relShip = TRUE ;
			}
		}

		__DBGpr_int(" Relation Ship ", relShip );
		End ;
		return relShip ;
}
/*----------------------------------------------------------------------------*/
end implementation VDSroot ;
