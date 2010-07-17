class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ex.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"

#include "ACrg_collect.h"
#include "parametric.h"

#include "vs.h"
#include "vsplatedef.h"

#include "EMSmsgdef.h"

#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

#include "vderrmacros.h"

#include "SFdef.h"

from  VSfeature		import  VSgetSupports;
from  EMSsubbs		import  EMproject_curve_along_surface_normals;
from  GRgraphics	import  GRcopy;
from  GRgraphics	import  GRdelete;
from  EMSsubbs		import  EMextend_by_dist;
from  NDmacro		import  ACgive_structure;


long   SFprojStfnrAxisOntoSurf (
  long				*msg,		/* O - return status	    */
  struct GRid			*sf,		/* I - surface onto which stfnr
					               axis to be projected */
  struct GRmd_env		*sf_env,	/* I - mod_env of surface   */
  struct GRid			*stfnr,		/* I - stfnr to be projected*/
  struct GRmd_env		*stfnr_env,	/* I - mod_env of stfnr	    */
  struct GRvg_construct		*cst,		/* I - cst		   */
  GRobjid			*proj_obj	/* O - projected object	   */
)
{
long			sts, nb_proj;
struct GRlc_info	curve_info,
			side_info;
IGRdouble		dists_in[4], dists_out[4];
int			xtend_opt;
GRobjid			sf_copy, extended_obj, *loc_proj_obj = NULL;
IGRdouble		chtol_db;
int			count;
VSsuppList		supports;
struct GRmd_env		*cst_env = NULL;
struct ret_struct	rs;
int			index = -1;  /* unused ASSOC flag */


	if( !msg || !sf || !sf_env || !stfnr || !stfnr_env || !cst || 
	    !proj_obj )
	{
	   sts = OM_E_INVARG;
	   *msg = MSINARG;
	   goto wrapup;
	}

	sts = OM_S_SUCCESS;
	*msg = MSSUCC;


	cst_env = cst->env_info;

	/*
	 * get support axis of the beam
	 */
	sts = om$send ( msg = message VSfeature.VSgetSupports (
					msg,
					stfnr_env,
					&count,
					supports ),
		   targetid = stfnr->objid,
		   targetos = stfnr->osnum,
		   senderid = NULL_OBJID );
	VDS_ERR_HNDLR("VSfeature.VSgetSupports",sts,*msg,VD_VERBOSE,wrapup);

/*
****** Centriodal axis is risky becuase, stiffener may lie outside the surface.
****** But this is more correct annd may to be done in future.

	*
	* get centroidal axis of the beam
	*
	struct GRid		BmCentAxisId;
			TmpModEnv;  * for constructing outside range tree *
	sts = SFgetBeamCentroidalAxis (  msg,
					 StfnrList[ii],
					 VSplEnv,
					 &TmpModEnv,
					 &BmCentAxisId );
	VDS_ERR_CONTINUE( "SFgetBeamCentroidalAxis", sts, *msg, VD_VERBOSE );
*/

	/* project support axis onto surface
	 *
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */

	curve_info.located_obj	= supports[1].obj_id;
	curve_info.module_info	= *stfnr_env;
	side_info.located_obj	= *sf;
	side_info.module_info	= *sf_env;

	/*
	 * Project curve.
	 */
	sts = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							cst,
							TRUE,
							TRUE,
							&nb_proj,
							&loc_proj_obj,
							msg ),
		senderid = NULL_OBJID,
		targetid = sf->objid,
		targetos = sf->osnum  );

	__DBGpr_int( "number of projections", nb_proj ) ;

	if( nb_proj < 1 )
	{
	  /* Projection fails when the curve projects onto edge of the surface.
	   * Try following :
	   * Copy the surface.
	   * Extend the copy of surface by 2*cht
	   * Project curve onto extended surface
	   * delete copy
	   */

	   sts = om$send ( msg       = message GRgraphics.GRcopy ( 
						msg,
						sf_env,
                                   		cst_env,
						&sf_copy ),
			   senderid  = NULL_OBJID,
			   targetid  = sf->objid,
			   targetos  = sf->osnum );
	   if(!(sts & *msg & 1))
	   {
	     printf("SFSFprojStfnrAxisOntoSurf : GRgraphics.GRcopy failure\n");
	     goto wrapup;
	   }

	   BSEXTRACTPAR ( msg, BSTOLCHRDHT, chtol_db );

	   dists_in[0] = 
	   dists_in[1] = 
	   dists_in[2] = 
	   dists_in[3] = 2*chtol_db;

	   xtend_opt = 	EMS_opt_extendS_deextend_if_needed |
			EMS_opt_extendS_reparametrize_surface ;

	   sts = om$send ( msg = message EMSsubbs.EMextend_by_dist (
					msg,
					cst_env,
					dists_in,
					dists_out,
					xtend_opt,
					&extended_obj ),
			   senderid = NULL_OBJID,
			   targetid = sf_copy,
			   targetos = cst_env->md_id.osnum );
	   VDS_ERR_HNDLR("EMSsubbs.EMextend_by_disp", sts, *msg, VD_VERBOSE,
			 wrapup );

	   side_info.located_obj.objid	= extended_obj;
	   side_info.located_obj.osnum	= cst_env->md_id.osnum;
	   side_info.module_info	= *(cst_env);

	   sts = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							cst,
							TRUE,
							TRUE,
							&nb_proj,
							&loc_proj_obj,
							msg ),
			senderid = NULL_OBJID,
			targetid = extended_obj,
			targetos = cst_env->md_id.osnum );

	   sts = om$send( msg = message GRgraphics.GRdelete( 
					msg, cst_env ),
			  senderid = NULL_OBJID,
			  targetid = extended_obj,
			  targetos = cst_env->md_id.osnum );

	   if ( nb_proj < 1 )
	   {
	      printf("SFprojStfnrAxisOntoSurf : projection of curve failed\n");
	      sts = om$send(  msg   = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMbrNamAttr,
					&rs, stfnr_env ),
			   senderid = NULL_OBJID,
			   targetid  = stfnr->objid,
			   targetos  = stfnr->osnum );
	      VDS_ERR_RPT("Getting name of stiffener", sts, *msg, VD_VERBOSE );

	      sts = SFwriteToLogFile( msg, rs.var.text_st.text_string, 
				      SF_STIFFENER, *stfnr ); 
	      goto wrapup;
	   }
	   else
	      *proj_obj = loc_proj_obj[0];


/*		if( msg == MANOMEMORY ) {
			/*
			 * No dynamic memory.
			 *
			 msg = EMS_E_NoDynamicMemory ;
			 status = OM_E_NODYNMEM ;
		} else {
			/*
			 * No solution found.
			 *
			 msg = EMS_W_NoSolution ;
			 status = OM_W_ABORT ;
		}
*/
	} /* if( nb_proj < 1 ) */
	else
	  *proj_obj = loc_proj_obj[0];

wrapup:

  if ( loc_proj_obj )  free ( loc_proj_obj );
  return sts;

}

end implementation Root;
