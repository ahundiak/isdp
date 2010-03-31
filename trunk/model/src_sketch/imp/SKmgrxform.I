class implementation SKmgr;
/*

Name
  GRxform

Abstract
  This method transforms the geometry of an SKmgr by a matrix.  

Synopsis
     *obj_dsenv   GRmd_env       md_env structure 
     *matrix_type IGRshort       the type of the matrix as determined
                                 by math function MAtypemx()
     matrix       IGRmatrix      the given transformation matrix
     *newobjid    GRobjid        objid of the transformed object
     *msg         IGRlong        completion code

Description

Return Value

Notes

Index

Keywords
  profile

History
  08/18/93 : Rajiv Agrawal : created
  11/24/93 : Rajiv Agrawal : Added support for b-spline movement.  Move the internal poles
                             by the same amount.
  02/01/94 : Rajiv Agrawal : Changed my_id to comp_list[i].objid when finding sub_components
                             to transform bspline.  (TR119416544).
 */

#include "gocmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "bsmult_mats.h"
#include "ma.h"
#include "maptsxfor.h"
#include "marptsxfo.h"

from SKvariable import SKputvar;

method GRxform(long *msg; struct GRmd_env *md_env; 
               short *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
  short 		mattyp_to_xy;
  IGRushort		gmtype;
  OMuint 		num_comps, num_sub_comps;
  int 			i, j, stat_OM;
  long 			msg_loc, one=1;
  double 		deltax, deltay;
  IGRpoint 		origpt;
  IGRvector 		xaxis, zaxis, tvec;
  IGRmatrix 		mat_to_xy, outmat, hmat, hmat_t;
  struct GRid		my_grid;
  struct SKsolvevars 	*varlist, *ptlist;
  struct SKvarinfo      *varinfo;
  OM_S_CHANSELECT       chan_to_comps;
  OM_S_OBJECT_LINKAGE 	*comp_list, *sub_comp_list;
  IGRboolean aflag=0,reset_shift=0;
  IGRpoint shift;
  extern void           SKgetgeomtype(), SKgetmatrix();

   
  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  *newobjid = my_id;
  
  aflag = pwIsActivationOn();
  if (aflag)
  {
     shift[0] = md_env->md_env.matrix[3];
     shift[1] = md_env->md_env.matrix[7];
     shift[2] = md_env->md_env.matrix[11];
     md_env->md_env.matrix[3] = 0.0;
     md_env->md_env.matrix[7] = 0.0;
     md_env->md_env.matrix[11] = 0.0;
     reset_shift = 1;
  }
  
  /*
   * Get the transformation from world xyz to profile's xy coodinate system.
   */
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
                           SK_OPT_GET_XYZ_TO_XY | SK_OPT_NO_ORIGIN, 
                           &md_env->md_env.matrix_type, 
                           md_env->md_env.matrix, 
                           &mattyp_to_xy, mat_to_xy), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  BSmult_mats(4, 4, mat_to_xy, FALSE, 4, 4, matrix, FALSE, outmat, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
  
  deltax = outmat[3];
  deltay = outmat[7];

  /*
   * Apply the deltas to all the SKptvars of the profile.
   */
  varlist = NULL;
  stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
                           SK_GETVR_COMPRESSED, &varlist, NULL, NULL), 
                     targetid = my_id);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
 
  ptlist = varlist;
  while (ptlist)
  {
    if (ptlist-> props & VAR_PT)
    {
      ptlist->var[X] += deltax;
      ptlist->var[Y] += deltay;
      stat_OM = om$send (msg = message SKvariable.SKputvar 
                               (&msg_loc, NULL,NULL,NULL, ptlist->var),
                         targetid = ptlist->varobj);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
    }
    ptlist = ptlist->next;
  }

  if (aflag)
  {
    if (reset_shift)
    {
     md_env->md_env.matrix[3] = shift[0];
     md_env->md_env.matrix[7] = shift[1];
     md_env->md_env.matrix[11] = shift[2];
    }
  }
  
  /*
   * Get the local coord system of the profile's ref-plane.
   */
  om$send ( msg = message SKmgr.SKgetornt (&msg_loc, origpt, xaxis, zaxis),
            targetid = my_id );
  SKgetmatrix ( &msg_loc, origpt, zaxis, xaxis, hmat, hmat_t);

  tvec[0] = deltax;
  tvec[1] = deltay;
  tvec[2] = 0.0;
  MAptsxform (&msg_loc, &one, hmat_t, tvec, tvec);
  for (i = 0; i <= 2; i++)
    tvec[i] -= origpt[i];
  
  /*
   * Move the poles of any b-spline profile element.
   */
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  stat_OM = om$get_channel_count (objid = my_id,
                                  p_chanselect = &chan_to_comps,
                                  count = &num_comps);
  EMerr_hndlr (!(stat_OM & 1) || !num_comps, *msg, EMS_E_Fail, ret_end);
  comp_list = (OM_S_OBJECT_LINKAGE *) alloca (num_comps * sizeof (OM_S_OBJECT_LINKAGE));
  stat_OM = om$get_channel_objects ( list = comp_list, size = num_comps, 
                                     count = &num_comps, 
                                     objid = my_id, 
                                     p_chanselect = &chan_to_comps);
  if (!(stat_OM & 1)) goto ret_end;
  for (i=0; i<num_comps; i++)
  {
    SKgetgeomtype(comp_list[i].S_objid, comp_list[i].osnum, &gmtype);
    if (gmtype & SK_BSPLINE)
    {
      SKtrans_bspline (&msg_loc, md_env, comp_list[i].S_objid, comp_list[i].osnum,
                       tvec);
    }
    else if (gmtype & SK_COMPCURVE)
    {
      stat_OM = om$get_channel_count (objid = comp_list[i].S_objid,
                                      osnum = comp_list[i].osnum,
                                      p_chanselect = &chan_to_comps,
                                      count = &num_sub_comps);
      EMerr_hndlr (!(stat_OM & 1) || !num_sub_comps, *msg, EMS_E_Fail, ret_end);
      sub_comp_list = (OM_S_OBJECT_LINKAGE *) alloca (num_sub_comps * sizeof (OM_S_OBJECT_LINKAGE));
      stat_OM = om$get_channel_objects ( list = sub_comp_list, size = num_sub_comps, 
                                         count = &num_sub_comps, 
                                         objid = comp_list[i].S_objid, 
                                         osnum = comp_list[i].osnum,
                                         p_chanselect = &chan_to_comps);
      if (!(stat_OM & 1)) goto ret_end;
      for (j=0; j<num_sub_comps; j++)
      {
        SKgetgeomtype (sub_comp_list[j].S_objid, sub_comp_list[j].osnum, &gmtype);
        if (gmtype & SK_BSPLINE)
        {
          SKtrans_bspline (&msg_loc, md_env, sub_comp_list[j].S_objid, 
                           sub_comp_list[j].osnum, tvec);
        }
      }
    }
  }
  
  /*
   * Recompute the underlying profile geometry and constraint handles.
   */
  stat_OM = om$send (msg = message SKmgr.SKgeom_update 
                           ( &msg_loc, NULL, NULL, md_env), 
                      targetid = my_id );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  stat_OM = om$send ( msg = message SKmgr.SKconstr_update 
                             ( &msg_loc, 
                             SK_UPDATE_IMPCONSTRS | SK_UPDATE_EXPCONSTRS,
                             NULL, md_env), 
                      targetid = my_id );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  /*
   * Wipe out the Undo information of the profile since its no longer valid.
   */   
  varinfo = ME.SKmgr->oldvars;
  varinfo[0].varobj = NULL_OBJID;
  varinfo[1].varobj = NULL_OBJID;
  varinfo[2].varobj = NULL_OBJID;
  ME.SKmgr->props &= ~SK_MGR_STATE_SAVED;
  
  /*
   * Update my dependents by putting myself on the batch.
   */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  nd$wait_batch (type = GR_GEOM_POSTED, nb_obj = 1, l_object = &my_grid);

ret_end:
  if (varlist)
    SKfreevarlist (varlist, MAXINT);

  EMWRAPUP (*msg, stat_OM, "SKmgr.GRxform");
  return stat_OM;  
}

SKtrans_bspline (msg, md_env, bsp_id, bsp_os, tvec)
long *msg;
struct GRmd_env *md_env;
GRobjid bsp_id;
GRspacenum bsp_os;
IGRvector tvec;
{
  int 			j, stat_OM;
  long 			msg_loc;
  GRobjid               newcurve;
  struct GRpost_info    post_info;
  struct IGRbsp_curve   *curve;
  extern long 		EMgetabsg();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  
  EMgetabsg (&msg_loc, &md_env->md_env.matrix_type, md_env->md_env.matrix, 
             bsp_os, bsp_id, (char **)&curve);
  EMerr_hndlr (!(msg_loc & 1), *msg, EMS_E_Fail, ret_end);
  for (j=0; j<curve->num_poles; j++)
  {
    curve->poles[j*3+X] += tvec[X];
    curve->poles[j*3+Y] += tvec[Y];
    curve->poles[j*3+Z] += tvec[Z];
  }
  post_info.construct_flag = FALSE;
  stat_OM = om$send (msg = message GRvg.GRpostabsg 
                           (&msg_loc, md_env, &post_info, (char *) curve, &newcurve),
                     targetid = bsp_id,
                     targetos = bsp_os,
                     senderid = NULL_OBJID);
  EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKtrans_bspline" );
  return stat_OM;
}

SKxform_bspline (msg, md_env, bsp_id, bsp_os, trans_mat)
long *msg;
struct GRmd_env *md_env;
GRobjid bsp_id;
GRspacenum bsp_os;
IGRmatrix trans_mat;
{
  int 			stat_OM;
  long 			msg_loc;
  GRobjid               newcurve;
  struct GRpost_info    post_info;
  struct IGRbsp_curve   *curve;
  extern long 		EMgetabsg();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMgetabsg (&msg_loc, &md_env->md_env.matrix_type, md_env->md_env.matrix, 
             bsp_os, bsp_id, (char **)&curve);
  EMerr_hndlr (!(msg_loc & 1), *msg, EMS_E_Fail, ret_end);

  MArptsxform (&msg_loc, &curve->num_poles, &curve->rational, curve->weights,
               trans_mat, curve->poles, curve->poles);

  post_info.construct_flag = FALSE;
  stat_OM = om$send (msg = message GRvg.GRpostabsg 
                           (&msg_loc, md_env, &post_info, (char *) curve, &newcurve),
                     targetid = bsp_id,
                     targetos = bsp_os,
                     senderid = NULL_OBJID);
  EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKxform_bspline" );
  return stat_OM;
}

end implementation SKmgr;

