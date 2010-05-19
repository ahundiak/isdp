class implementation Root;

/*+fe
Function   VDconstruct_viewvol()

Abstract
  This function constructs a view vol given a solid, its env, context
  name and desc.

Arguments
  IGRlong               *msg          O    return status
  struct GRid		*solid        I    object id of the solid
  struct GRmd_env	*solid_env    I    mod env of the solid
					   same as returned by locate.
  char			*name         I    name of view vol.
  char			*desc         I    description of view vol.
					   = NULL, if no description.
  struct GRid		*vvol_id      O    object id of the constructed
					   view volume.
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "parametric.h"
#include "godef.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "vderrmacros.h"

extern OMuword		OPP_VDviewvol_class_id;
extern struct GRid	NULL_GRID;

from   GRgraphics  import   GRconstruct;
from   VDviewvol   import   VDvv_set_name_desc;

long  VDconstruct_viewvol( 
  long			*msg,
  struct GRid		*solid,
  struct GRmd_env	*solid_env,
  char			*name,
  char			*desc,
  struct GRid		*vvol_id
)
{

  long			  sts;
  struct IGRdisplay	  disp;
  short			  level;
  struct GRas		  assoc_lis;
  struct GRvg_construct	  cnst_list;
  int			  numberOfBytes,
			  BytesReceived;
  struct GRid		  src_obj,
			  viewvol,
			  VolMgr,
			  ctx_id; 
  struct GRmd_env	  mod_env;


  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

  if ( !name )
  {
    *msg = MSFAIL;
    sts = OM_E_ABORT;
    goto wrapup;
  }


  /* check if volume manager exists. If not create one */
  sts = VDget_vol_mgr ( NULL, &VolMgr );
  if ( !(sts&1) )  sts = VDcrt_vol_mgr();

  numberOfBytes = sizeof ( IGRshort );
  gr$get_active_layer(  msg     = msg,
                        sizbuf  = &numberOfBytes,
                        buffer  = &level,
                        nret    = &BytesReceived );

  numberOfBytes = sizeof ( struct IGRdisplay );
  gr$get_active_display( msg     = msg,
                         sizbuf  = &numberOfBytes,
                         buffer  = &disp,
                         nret    = &BytesReceived );

  numberOfBytes = sizeof ( struct GRmd_env );
  gr$get_module_env  (	 msg     = msg,
                         sizbuf  = &numberOfBytes,
                         buffer  = &mod_env,
                         nret    = &BytesReceived );

  cnst_list.msg      = msg;
  cnst_list.env_info = &mod_env;
  cnst_list.display  = &disp;
  cnst_list.geometry = NULL;
  cnst_list.newflag  = FALSE;
  cnst_list.level    = level;
  cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst_list.class_attr = ( IGRchar *) &assoc_lis;
  cnst_list.name       = NULL;


  sts = as$make_source (   go_grid  =   *solid,
			   mod_env  =   solid_env,
			   as_os    =   mod_env.md_id.osnum,
			   as_grid  =   &src_obj );
  __DBGpr_obj("src_obj", src_obj );
  if ( !(sts&1) )
  {
     printf("VDconstruct_viewvol : as$make_source failure\n");
     goto wrapup;
  }

  sts = GRfindcontext ( msg,
			&(solid_env->md_env.matrix_type),
			solid_env->md_env.matrix,
			&(solid->osnum),
			&ctx_id );
  if( !(sts & *msg & 1) ) ctx_id.objid = NULL_OBJID;

  assoc_lis.num_parents = 1;
  assoc_lis.parents  = &src_obj;
  assoc_lis.context  = &ctx_id;
  assoc_lis.go_attr  = NULL;
  assoc_lis.as_attr  = NULL;

  viewvol.osnum = mod_env.md_id.osnum;
  sts = om$construct (  osnum = viewvol.osnum,
			classid = OPP_VDviewvol_class_id,
			p_objid = &viewvol.objid,
			msg = message GRgraphics.GRconstruct ( &cnst_list ) );
  VDS_ERR_HNDLR ( "om$construct", sts, 1, VD_VERBOSE, wrapup);
  if ( vvol_id ) *vvol_id = viewvol;

  sts = om$send ( msg = message VDviewvol.VDvv_set_name_desc (
						msg,
						name,
						desc ),
		  senderid = NULL_OBJID,
		  targetid = viewvol.objid,
		  targetos = viewvol.osnum );
  VDS_ERR_HNDLR("VDviewvol.VDvv_set_name_desc", sts, *msg, VD_VERBOSE, wrapup);


wrapup:
   return sts;
}

end implementation Root;
