/* $Id: VDconstMV.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmdlv/func / VDconstMV.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDconstMV.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
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
# Revision 1.2  1995/08/23  23:39:18  pinnacle
# Replaced: vdmdlv/func/*.I for:  by tlbriggs for vds.240
#
 *
 * History:
 *	11-03-1994  Raju   	Creation
 *    	08/23/95    tlb		Modified to use _MALLOC, _FREE
 *
 *************************************************************************/

class implementation Root;
/*+fe
Function   VDconstruct_mdlview()

Abstract
  This function constructs a model view given name, desc(optional),
  view volume ids and query ids.

Arguments
  IGRlong		*msg	      O    return status
  char			*name         I    name of model view.
  char			*desc         I    description of model view.
					   = NULL, if no description.
  int			num_vv	      I    no. of view vols.
  struct GRid		*vv_list      I    object ids of the view vols
  struct GRmd_env	*vv_env_list  I    env list of view vols.
					   = NULL, current mod env is used for
					   view vols.
  int			num_qry	      I    no. of queris.
  struct GRid		*qry_list     I    object ids of queries.

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
#include "VDmem.h"

extern OMuword		OPP_VDmdlview_class_id;
extern struct GRid	NULL_GRID;

from   GRgraphics  import   GRconstruct;
from   VDmdlview   import   VDmv_set_name_desc;

long  VDconstruct_mdlview(
  long			*msg,
  char			*name,
  char			*desc,
  int			num_vv,
  struct GRid		*vv_list,
  struct GRmd_env	*vv_env_list,
  int			num_qry,
  struct GRid		*qry_list,
  struct GRmd_env	*qry_env_list,
  struct GRid		*mdlvw_id
)
{

  long			  sts;
  struct IGRdisplay	  disp;
  short			  level;
  struct GRas		  assoc_lis;
  struct GRvg_construct	  cnst_list;
  int			  numberOfBytes,
			  BytesReceived,
			  ii, jj;
  struct GRid		  *src_obj = NULL,
			  *ctx_obj = NULL,
			  mdlview,
			  MdlvwMgr;
  struct GRmd_env	  mod_env, vv_env, qry_env;


  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

  if ( !name || ( num_vv == 0 && num_qry == 0) )
  {
    *msg = MSFAIL;
    sts = OM_E_ABORT;
    goto wrapup;
  }


  /* check if model view manager exists. If not create one */
  sts = VDget_mdlvw_mgr ( NULL, &MdlvwMgr );
  if ( !(sts&1) )  sts = VDcrt_mdlvw_mgr();

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
  cnst_list.class_attr = (IGRchar *) &assoc_lis;
  cnst_list.name       = NULL;

  /*
   * allocate mamory
   */
  src_obj = _MALLOC ((num_vv+num_qry), struct GRid);
  _CheckMem (src_obj, sts, *msg, wrapup);

  ctx_obj = _MALLOC ((num_vv+num_qry), struct GRid);
  _CheckMem (ctx_obj, sts, *msg, wrapup);

  vv_env = mod_env;
  for ( ii=0; ii<num_vv; ii++)
  {
    if ( vv_env_list ) 	vv_env = vv_env_list[ii];

    sts = as$make_source ( go_grid  =   vv_list[ii],
			   mod_env  =   &vv_env,
			   as_os    =   mod_env.md_id.osnum,
			   as_grid  =   &src_obj[ii] );
    __DBGpr_obj("src_obj", src_obj[ii] );
    if ( !(sts&1) )
    {
	printf("VDconstruct_mdlview : as$make_source failure\n");
	goto wrapup;
    }

    sts = GRfindcontext ( msg,
			  &vv_env.md_env.matrix_type,
			  vv_env.md_env.matrix,
			  &(vv_list[ii].osnum),
			  &ctx_obj[ii] );
    if( sts == OM_S_SUCCESS && *msg == MSSUCC )
    {
/*
          if(context->osnum == located_obj->osnum)
            {
             /*|context dans le meme os * /
            }
*/
    }
    else
      ctx_obj[ii].objid = NULL_OBJID;
  }

  qry_env = mod_env;
  for ( ii=0; ii<num_qry; ii++)
  {
    jj = num_vv + ii;

    if ( qry_env_list )  qry_env = qry_env_list[ii];
    sts = as$make_source ( go_grid  =   qry_list[ii],
			   mod_env  =   &qry_env,
			   as_os    =   mod_env.md_id.osnum,
			   as_grid  =   &src_obj[jj] );
    __DBGpr_obj("src_obj", src_obj[jj] );
    if ( !(sts&1) )
    {
	printf("VDconstruct_mdlview : as$make_source failure\n");
	goto wrapup;
    }

    sts = GRfindcontext ( msg,
			  &qry_env.md_env.matrix_type,
			  qry_env.md_env.matrix,
			  &(qry_list[ii].osnum),
			  &ctx_obj[jj] );
    if( !( sts & *msg & 1 ) )
	ctx_obj[jj].objid = NULL_OBJID;
  }

  assoc_lis.num_parents = num_vv + num_qry;
  assoc_lis.parents  = src_obj;
  assoc_lis.context  = ctx_obj;
  assoc_lis.go_attr  = NULL;
  assoc_lis.as_attr  = NULL;


  mdlview.osnum = mod_env.md_id.osnum;
  sts = om$construct (  osnum = mdlview.osnum,
			classid = OPP_VDmdlview_class_id,
			p_objid = &mdlview.objid,
			msg = message GRgraphics.GRconstruct ( &cnst_list ) );
  VDS_ERR_HNDLR ( "om$construct", sts, 1, VD_VERBOSE, wrapup);
  __DBGpr_obj ( "model view object =", mdlview );
  if ( mdlvw_id ) *mdlvw_id = mdlview;

  sts = om$send ( msg = message VDmdlview.VDmv_set_name_desc (
						msg,
						name,
						desc ),
		  senderid = NULL_OBJID,
		  targetid = mdlview.objid,
		  targetos = mdlview.osnum );
  VDS_ERR_HNDLR("VDmdlview.VDmv_set_name_desc", sts, *msg, VD_VERBOSE, wrapup);


wrapup:
   _FREE ( src_obj );
   _FREE ( ctx_obj );
   return sts;
}

#if 0
void tmp_const_mdlvw_call()
{
long  msg, sts;
struct GRid vv[5], qry[5];
int    num_vvol, num_qry;
char	mdlvw_name[10], mdlvw_desc[15];
struct	GRmd_env   mod_env, mv_env[4];
int		   numberOfBytes, BytesReceived;


  numberOfBytes = sizeof ( struct GRmd_env );
  gr$get_module_env  (	 msg     = &msg,
                         sizbuf  = &numberOfBytes,
                         buffer  = &mod_env,
                         nret    = &BytesReceived );
  mv_env[0] = mv_env[1] = mv_env[2] = mv_env[3] = mod_env;


  vv[0].objid = 377;
  vv[0].osnum = 2;
  vv[1].objid = 423;
  vv[1].osnum = 2;
  qry[0].objid = 367; qry[0].osnum = 2;
  qry[1].objid = 370; qry[1].osnum = 2;
  num_vvol = 2; num_qry = 2;
  strcpy( mdlvw_name, "mdlvw1" );
  strcpy( mdlvw_desc, "mdlvw-desc1" );
  sts = VDconstruct_mdlview (	&msg,
				mdlvw_name,
				mdlvw_desc,
				num_vvol,
				vv,
				NULL,
				num_qry,
				qry,
				NULL,
				NULL
			    );

}
#endif

end implementation Root;
