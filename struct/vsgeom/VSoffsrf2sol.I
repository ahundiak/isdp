/* $Id $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsgeom/VSoffsrf2sol.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/18/00        Rama Rao        Implemented VSget_actual_go(()..
 * -------------------------------------------------------------------*/

class implementation EMSsubbs ;

#include <math.h>
#include "msdef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSssprops.h"
#include "vspart.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "growner.h"
#include "vsdbgmacros.h"

#define  vsDEBUG        1
#define  vserrDEBUG     1

extern IGRboolean	ASbroadcast_in_progress ;
extern long		EMoffset_surface_to_solid(),
			EMsweep_surface_via_lift_face_mod() ;
extern OMuword		OPP_EMSplane_class_id, OPP_ASnode_class_id ;

from NDnode     import  ASreturn_go ;
from EMSplane	import	EMplaneDef ;

void	VSget_actual_go( struct GRid		*surfId,
			 struct GRmd_env	*surfEnv,
			 struct GRid		*grId,
			 struct GRmd_env	*grEnv )
{
IGRlong			sts;
struct GRid		locsurfId;
struct GRmd_env		locsurfEnv;

        if( vs$is_ancestry_valid( object  = surfId,
                                  classid = OPP_ASnode_class_id ) )
        {
             sts = om$send(  msg     = message NDnode.ASreturn_go(
                                               &locsurfId,
                                               &locsurfEnv._MATRIX_TYPE,
                                               locsurfEnv._MATRIX  ),
                            senderid = NULL_OBJID,
                            targetid = surfId->objid,
                            targetos = surfId->osnum ) ;
              if( sts&1 )
              {
		locsurfEnv._MD_OS = locsurfId.osnum;
		ex$get_modid(   mod_osnum = locsurfEnv._MD_OS,
				mod_id	  = &locsurfEnv._MD_ID );
		VSget_actual_go( &locsurfId, &locsurfEnv, grId, grEnv );
              }
	      else
	      {
		*grId  = *surfId;
		*grEnv = *surfEnv;
	      }
        }
	else
	{
	      	*grId  = *surfId;
		*grEnv = *surfEnv;
	}
}
					
/*----------------------------------------------------------------------------*/
long VSoffset_surface_to_solid(	msg,
				surfEnv,
				surfId,
				offsetDist,
				isPlanar,
				useNatNorm,
				cstList,
				offSolId )

/*
 * Creates an offset solid given a surface, optimizes the process when the
 * input surface is a plane.
 * This function is interfaced by macro vs$offset_surface_to_solid.
 */

long			*msg ;
struct GRmd_env		*surfEnv ;
struct GRid		*surfId ;
double			offsetDist ;
int			isPlanar,
			useNatNorm ;
struct GRvg_construct	*cstList ;
struct GRid		*offSolId ; {

	long			sts ;
	IGRboolean		saveBroadcast ;	/* Save-broadcast flag	*/
	unsigned char		props ;
	struct GRlc_info	Surf ;
	double			offTol ;
	short			grprops,
				action ;
	struct GRid		locsurfId ;
	struct GRmd_env		locsurfEnv ;

	/*
	 * EMS objects now may be associative, set `ASbroadcast_in_progress'
	 * to TRUE to avoid dependency copy which might take place in the
	 * EMS software invoked below. And reset it to its previous value as
	 * you exit this function.
	 */
	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	offSolId->objid	= NULL_OBJID ;
	offSolId->osnum = cstList->env_info->_MD_OS ;

	VSget_actual_go( surfId, surfEnv, &locsurfId, &locsurfEnv ); 
/*
        if( vs$is_ancestry_valid( object  = surfId,
                                  classid = OPP_ASnode_class_id ) )
        {
             sts = om$send(  msg     = message NDnode.ASreturn_go(
                                               &locsurfId,
                                               &locsurfEnv._MATRIX_TYPE,
                                               locsurfEnv._MATRIX  ),
                            senderid = NULL_OBJID,
                            targetid = surfId->objid,
                            targetos = surfId->osnum ) ;
              if( sts&1 ) 
              {
		   locsurfEnv._MD_OS = locsurfId.osnum ;
                   ex$get_modid(   mod_osnum = locsurfEnv._MD_OS,
                                   mod_id    = &locsurfEnv._MD_ID ) ;
              }
	      else 
	      {
		   locsurfId  = *surfId ;
		   locsurfEnv = *surfEnv ;
	      }
	}
	else
	{
	   locsurfId  = *surfId ;
	   locsurfEnv = *surfEnv ;
	}
*/

	sts = om$send(	msg	= message EMSsubbs.EMget_props( msg, &props ),
			senderid= locsurfId.objid,
			targetid= locsurfId.objid,
			targetos= locsurfId.osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", next ) ;

	if( props & EMSIS_NRML_REVERSED ) {
		useNatNorm = !useNatNorm ;
	}

	next :
	Surf.located_obj = locsurfId ;
	Surf.module_info = locsurfEnv ;

	if( isPlanar == -1 ) {
		isPlanar = vs$is_ancestry_valid(
					object	= &locsurfId,
					classid	= OPP_EMSplane_class_id ) ;
	}

	/*
	 * Check offset distance against offset tolerance.
	 */
	BSEXTRACTPAR( msg, BSTOLOFFSET, offTol ) ;
	if( fabs( offsetDist ) < offTol ) offsetDist = offTol ;

	if( isPlanar ) {
		struct IGRplane		plane ;
		IGRvector		unitNormal ;
		IGRpoint		origin,
					offsetPnt ;
		int			i ;

		plane.point	= origin ;
		plane.normal	= unitNormal ;

		/*
		 * Note : message returns a unit vector for the normal.
		 * If message not recognized go to general case.
		 */
		sts = om$send(	msg	= message EMSplane.EMplaneDef(
						msg,
						&locsurfEnv._MATRIX_TYPE,
						locsurfEnv._MATRIX,
						&plane ),
				senderid= locsurfId.objid,
				targetid= locsurfId.objid,
				targetos= locsurfId.osnum ) ;
		__CheckRC( sts, *msg, "EMSplane.EMplaneDef", OFFSET_SF_TO_SOLID ) ;

		if( !useNatNorm ) offsetDist = -offsetDist ;

		for( i = 0 ; i < 3 ; i++ ) {
			offsetPnt[i] = origin[i] + offsetDist * unitNormal[i] ;
		}

		sts = EMsweep_surface_via_lift_face_mod(&Surf,
							origin,
							offsetPnt,
							cstList,
							NULL_OBJID,
							&offSolId->objid,
			/* Symmetric dist. option */	FALSE,
							msg ) ;
		if( !( sts & 1 & *msg ) ) goto OFFSET_SF_TO_SOLID ;

	} else {
		OFFSET_SF_TO_SOLID :

		sts = EMoffset_surface_to_solid(&Surf,
						offsetDist,
						useNatNorm,
						cstList,
						locsurfId.objid,
						&offSolId->objid ) ;

		*msg = *cstList->msg ;
		if( !( sts & 1 & *msg ) ) {
			sts = OM_W_ABORT ; goto wrapup ;
		}
	}

	/*
	 * It seems that the properties field is ignored by either
	 * EMsweep_surface_via_lift_face or EMoffset_surface_to_solid ...
	 */
	grprops	= cstList->properties ;
	action	= 1 ;
	sts = om$send(	msg	= message GRgraphics.GRchgprops(
						msg, &action, &grprops ),
			senderid= offSolId->objid,
			targetid= offSolId->objid,
			targetos= offSolId->osnum ) ;


	wrapup :
		ASbroadcast_in_progress = saveBroadcast ;
		return sts ;

} /* VSoffset_surface_to_solid */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
