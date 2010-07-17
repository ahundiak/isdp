/*
	I/STRUCT
*/
class implementation EMSsubbs ;

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "growner.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMS.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsiomacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsallocsf.h"
#include "bsactusplsf.h"
#include "bsfreesf.h"

from EMSgencompsf	import EMmake_comp ;
from EMSsfstitch	import EMmake_comp ;
from GRowner		import GRget_number_components ;

extern OMuword		OPP_EMSsfstitch_class_id,
			OPP_EMSgencompsf_class_id,
			OPP_EMSgenbs_class_id ;
extern void		VSresetObjidList() ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSrecomposite_gensurf_with_compcurve( msg, genlSfEnv,
						genlSfId,
						compCvEnv,
						compCvId,
						compSfEnv,
						compSfSymb,
						compSfId )
/*
 * This function interfaced by macro "vs$recomposite_surface".
 */
long			*msg ;
struct GRmd_env		*genlSfEnv,
			*compCvEnv,
			*compSfEnv ;
struct GRsymbology	*compSfSymb ;
struct GRid		*genlSfId,
			*compCvId,
			*compSfId ; {

	long		sts ;		/* OM return code		*/
	int		nbSplit,	/* Count of split points	*/
			i ;		/* Loop-on-patches index	*/
	IGRdouble	gap ;		/* Gap between parameters	*/
	struct IGRbsp_surface
			*genlSfGeom,	/* Geometry of general surface	*/
			*patchGeom ;	/* Geometry of one patch	*/
	OM_S_OBJID	*patchList ;	/* List of patches		*/
	struct GRvg_construct
			cst ;		/* Construction list		*/
	struct GRid	patch ;		/* GRid of one patch		*/

	patchList = NULL ; genlSfGeom = patchGeom = NULL ;
	compSfId->objid = NULL_OBJID ;

	sts = om$send(	msg	= message GRowner.GRget_number_components(
								msg, &nbSplit ),
			senderid= compCvId->objid,
			targetid= compCvId->objid,
			targetos= compCvId->osnum ) ;
	__CheckRC( sts, *msg, "GRowner.GRget_number_components", wrapup ) ;

	/*
	 * T-parameters are equally spaced around the curve, and corresponds
	 * exactly to U-parameters on the surface where splitting is wanted.
	 */
	gap = 1. / (double) nbSplit ;

	/*
	 * Get geometry of general surface, and alloc room for patches.
	 */
	sts = vs$get_geometry(	msg	= msg,
				grobjId	= genlSfId,
				grobjEnv= genlSfEnv,
				geometry= &genlSfGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	if( !( patchList = _MALLOC( nbSplit, OM_S_OBJID ) ) ) vs$mem_fail() ;
	VSresetObjidList( nbSplit, patchList ) ;

	BSallocsf(	genlSfGeom->u_order,
			genlSfGeom->v_order,
			genlSfGeom->u_num_poles,
			genlSfGeom->v_num_poles,
			genlSfGeom->rational,
			genlSfGeom->num_boundaries,
			&patchGeom,
			msg ) ;
	if( BSERROR( *msg ) ) vs$mem_fail() ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= compSfEnv,
				Level		= compSfSymb->level,
				Display		= &compSfSymb->display_attr,
				Newflag		= FALSE,
				Geometry	= patchGeom,
				Properties	= GRIS_DISPLAYABLE
						  | GRIS_LOCATABLE
						  | GRIS_NEW,
				Cnst_list	= cst ) ;

	for( i = 0 ; i < nbSplit ; i++ ) {
		/*
		 * Extract split patches form general surface.
		 */
		BSactusplsf(	genlSfGeom,
				gap * i,
				gap * (i+1),
				patchGeom,
				msg ) ;
		if( BSERROR( *msg ) ) {
			*msg = EMS_E_SurfaceError ; sts	= OM_W_ABORT ;
			goto wrapup ;
		}

		/*
		 * Construct surface objects and put some topology onto the
		 * patches for composite surface creation to work.
		 */
		vs$dotsInStsFld() ;

		sts = om$construct(	classid	= OPP_EMSgenbs_class_id,
		  			p_objid	= patchList + i,
  					osnum	= compSfEnv->_MD_OS ) ;
  		if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }

		sts = om$send(	msg	= message GRgraphics.GRconstruct( &cst),
				senderid= patchList[i],
				targetid= patchList[i],
				targetos= compSfEnv->_MD_OS ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

		patch.objid	= patchList[i] ;
		patch.osnum	= compSfEnv->_MD_OS ;

		sts = vs$make_natural_boundary(
					msg		= msg,
					surfaceEnv	= compSfEnv,
					surfaceId	= &patch ) ;
		__CheckRC( sts, *msg, "vs$make_natural_boundary", wrapup ) ;

	}

	compSfId->osnum = compSfEnv->md_id.osnum ;
	sts = om$construct(	classid	= OPP_EMSgencompsf_class_id,
	  			p_objid	= &compSfId->objid,
  				osnum	= compSfId->osnum ) ;
  	if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }

	sts = om$send(	msg	= message GRgraphics.GRconstruct( &cst ),
			senderid= compSfId->objid,
			targetid= compSfId->objid,
			targetos= compSfId->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	vs$dotsInStsFld() ;

	sts = om$send(	msg	= message EMSgencompsf.EMmake_comp(
								msg,
								nbSplit,
								patchList,
								compSfEnv ),
			senderid= compSfId->objid,
			targetid= compSfId->objid,
			targetos= compSfId->osnum ) ;
	if( *msg == EMS_I_Fail ) *msg = EMS_E_NoSolution ;
	__CheckRC( sts, *msg, "EMSgencompsf.EMmake_comp", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :

		if( !( sts & 1 & *msg ) ) {
			if( !IF_NULL_OBJID( compSfId->objid ) ) {
				vs$bulk_delete(	grids	= compSfId,
						theEnv	= compSfEnv ) ;
			}
			vs$bulk_delete(	objids	= patchList,
					count	= nbSplit,
					theEnv	= compSfEnv ) ;
		}

		_FREE( genlSfGeom	) ;
		_FREE( patchList	) ;
		if( patchGeom ) { long rc ; BSfreesf( &rc, patchGeom ) ; }

		/*
		 * Delete general surface anyway.
		 */
		vs$bulk_delete(	grids	= genlSfId,
				theEnv	= genlSfEnv ) ;

		return sts ;

} /* VSrecomposite_gensurf_with_compcurve */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
