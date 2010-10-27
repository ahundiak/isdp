class implementation  Root;

/*
Name
   VDoffsetSolid

Description
   This function offsets a given solid by given offset. If the distance
is positive, solid will be offset outwards otherwise inwards. The solid is
offset symmtrically outwards/inwards.

Notes

Abstract

History
   09-13-1994  Raju   Creation
*/
#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "exdef.h"
#include "ex.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "parametric.h"
#include "godef.h"
#include "go.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "bserr.h"
#include "bsparameters.h"

#include "EMSopt.h"
# include "emsdef.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "EMSascmacros.h"

#include "vderrmacros.h"

from  EMSsurface  import  EMoffset;
from  GRgraphics  import  GRcopy;
from  GRgraphics  import  GRdelete;
from  EMSsolid	  import  EMorient_yourself;
from  EMSsfdpr	  import  EMgetsolidclass;



long  VDoffsetSolid(
  long			*msg,		/* O */
  struct GRid		*solid,		/* I */
  struct GRmd_env	*solid_env,	/* I */
  struct GRvg_construct *cst,		/* I */
  double		offset,		/* I */
  GRobjid		*off_solid	/* O */
)
{
long			sts;
IGRushort		options;
IGRboolean		offset_inward = FALSE;
IGRdouble		thickness,
			*vals_half_tk = NULL;
int			num_nooffsetsfs = 0,
			num_spec_thick = 0;
GRobjid			offsetobj;
struct GRobjid_set	*spec_tk_sf_sets = NULL;
struct EMSerror_help	*errkey_list = NULL;
char			sts_str[30];



  if ( !msg || !solid || !solid_env || !cst || !off_solid )
  {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
  }

  sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  __DBGpr_com("Entered VDoffsetSolid");
  __DBGpr_obj("Solid to be offset", *solid);

  *off_solid = NULL_OBJID;
  options = EMS_opt_offsetS_display | EMS_opt_offsetS_handlestop ;

  strcpy( sts_str, "OFFSETTING" );

  if ( offset < 0.0 )  offset_inward = TRUE;
  thickness = fabs ( offset );
  sts = om$send ( msg = message EMSsurface.EMoffset (
					    msg,
					    options,
					    &(solid_env->md_env.matrix_type),
					    solid_env->md_env.matrix,
					    cst,
					    offset_inward,
					    thickness,
					    num_spec_thick,
					    vals_half_tk,
					    spec_tk_sf_sets,
					    num_nooffsetsfs,
					    NULL,
					    sts_str,
					    &offsetobj,
					    errkey_list ),
		  targetid = solid->objid,
		  targetos = solid->osnum,
		  senderid = NULL_OBJID  );
#ifdef VDS_DBG
  /* checking return code only when in debug mode, because it
   * fails when solid is a component of SMSketchVol
   */
  VDS_ERR_RPT( "EMSsurface.EMoffset", sts, *msg, VD_VERBOSE );
#endif

  if ( !(sts&*msg&1) )
  {
     GRobjid		newobjid;

	/*  EMSoffset fails when the solid is a component of
	 *  SMSketchVol.  So copy to solid construction env, make
	 *  offset and delete copy.
	 */
	sts = om$send ( msg = message GRgraphics.GRcopy (
						msg, solid_env,
						cst->env_info, &newobjid ),
			targetid = solid->objid,
			targetos = solid->osnum,
			senderid = NULL_OBJID );
	VDS_ERR_HNDLR( "GRgraphics.GRcopy", sts, *msg, VD_VERBOSE, wrapup );

	sts = om$send ( msg = message EMSsurface.EMoffset (
					  msg,
					  options,
					  &(cst->env_info->md_env.matrix_type),
					  cst->env_info->md_env.matrix,
					  cst,
					  offset_inward,
					  thickness,
					  num_spec_thick,
					  vals_half_tk,
					  spec_tk_sf_sets,
					  num_nooffsetsfs,
					  NULL,
					  sts_str,
					  &offsetobj,
					  errkey_list ),
		  targetid = newobjid,
		  targetos = cst->env_info->md_id.osnum,
		  senderid = NULL_OBJID  );

        if( !(sts & *msg & 1 ) ) goto wrapup;
/* tr179601346
	VDS_ERR_HNDLR( "EMSsurface.EMoffset", sts, *msg, VD_VERBOSE, wrapup );
*/

	sts = om$send ( msg = message GRgraphics.GRdelete (
						msg, cst->env_info ),
			targetid = newobjid,
			targetos = cst->env_info->md_id.osnum,
			senderid = NULL_OBJID  );
	VDS_ERR_RPT( "GRgraphics.GRdelete", sts, *msg, VD_VERBOSE );
  }

  if ( sts&*msg&1 )
  {
	struct GRid	tmpObj1;

	/*
	 * The following code is adopted from "Make Composite Surface" command.
	 * Files : ECmkcompsfi.I, EFmksolid.I.
	 */
	sts = ems$make_comp_surf(  msg		= msg,
				   options	= NULL,
				   num_surfs	= 1,
				   surfaces	= &offsetobj,
				   construction_list = cst,
				   comp_surface = &tmpObj1 );
	VDS_ERR_HNDLR ( "make_comp_surf", sts, *msg, VD_VERBOSE, wrapup );

/*
	Experiments made :

	sts = om$get_classid (	objid = *off_solid,
				osnum = cst->env_info->md_id.osnum,
				p_classid = &ele_classid );
	*off_solid = tmp_obj2.objid;

	sts = om$send  ( msg = message EMSsfdpr.EMgetsolidclass(
						msg,
						newclass ),
			 targetid = *off_solid,
			 targetos = cst->env_info->md_id.osnum,
			 senderid = NULL_OBJID );
	VDS_ERR_RPT ( "orient", sts, *msg, VD_VERBOSE );

	sts = om$send  ( msg = message EMSsolid.EMorient_yourself(
						msg,
						NULL,
						cst->env_info ),
			 targetid = *off_solid,
			 targetos = cst->env_info->md_id.osnum,
			 senderid = NULL_OBJID );
	VDS_ERR_RPT ( "orient", sts, *msg, VD_VERBOSE );
*/

	sts = om$change_class ( osnum = cst->env_info->md_id.osnum,
				objid = tmpObj1.objid,
				classname = "EMSslstitch" );
	VDS_ERR_RPT ( "om$change_class", sts, MSSUCC, VD_VERBOSE );

	*off_solid = tmpObj1.objid;
/*
	It may be necessary to send this message in future.
	sts = om$send  ( msg = message EMSsolid.EMorient_yourself(
						msg,
						NULL,
						cst->env_info ),
			 targetid = *off_solid,
			 targetos = cst->env_info->md_id.osnum,
			 senderid = NULL_OBJID );
	VDS_ERR_RPT ( "orient", sts, *msg, VD_VERBOSE );
*/

  }
  

wrapup:
  /* some insurance */
  if ( *off_solid == NULL_OBJID ) *off_solid = solid->objid;

#ifdef VDS_DBG
  printf("\tOffset solid = [%d]\n", *off_solid );
#endif
  __DBGpr_com("Exiting VDoffsetSolid");

  return sts;
}

end implementation Root;
