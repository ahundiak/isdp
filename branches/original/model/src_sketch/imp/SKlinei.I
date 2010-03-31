/*

Name
  SKline

Abstract

Synopsis

Description
    Implements the methods needed to incorporate a line element into a
    profile.  2 SKptvars are created for every line.
    The points are checked to see if they are horizontal or vertical.

Return Value

Notes

Index

Keywords

History
  12/01/92 : Rajiv Agrawal : Massive cleanup and removal of duplicate code.  
  01/25/93 : Rajiv Agrawal : Removed SKcreate_constraints method.
  07/02/93 : Sudha         : Modified for BSprototypes ansification
  10/27/93 : Rajiv Agrawal : Removed debug method - now comes from SKgeometry.

 */

class implementation SKline;

#include <stdio.h>
#include <math.h>

#include "OMmacros.h"
#include "parametric.h"
#include "msdef.h"
#include "EMSopt.h"
#include "gocmacros.h"

#include "madef.h"
#include "mamulmx.h"
#include "maoptsxfo.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsparameters.h"
#include "bsdistptpt.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from SKvariable import SKgetvar;

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *mattyp_to_lxyz; IGRdouble *mat_to_lxyz)
{
 OM_S_CHANSELECT       geom_pts_chan;
 struct IGRpolyline    polyline;
 struct GRpost_info    post_info;
 IGRdouble             pts[6], length, lentol;
 IGRlong               stat_OM, msg_loc, rc;
 IGRint                i;
 GRobjid               newid;
 IGRushort     		xform_opts; 
 IGRshort 		four=4, mattyp;
 IGRdouble 		*mat;
 IGRmatrix 		mat_store;

 stat_OM = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 if (mattyp_to_lxyz && mat_to_lxyz)
 {
   xform_opts = SK_OPT_FULL_TRANSFORM;
   mattyp = md_env->md_env.matrix_type;
   if (mattyp != MAIDMX)
   {
     mat = mat_store;
      MAmulmx (&msg_loc, &four, &four, &four, md_env->md_env.matrix, mat_to_lxyz, mat);  
     /* MAmulmx (&msg_loc, &four, &four, &four, mat_to_lxyz, md_env->md_env.matrix, mat); */
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
     MAtypemx(&msg_loc, mat, &mattyp);
     /* mattyp = NULL;*/
   }
   else
   {
     mattyp = *mattyp_to_lxyz;
     mat = mat_to_lxyz;
   }
 }
 else
 {
   xform_opts = NULL;
   mattyp = md_env->md_env.matrix_type;
   mat = md_env->md_env.matrix;
 }

 polyline.num_points = 2;
 polyline.points = pts;
 post_info.construct_flag = FALSE;

 /*
  * Get the point varaibles in the world coordinate system.
  * For the time being, it is assumed that it is an identity
  * matrix.
  */

  EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);
  for (i = 0; i < 2; i++)
  {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                     xform_opts, &mattyp, mat, &pts[3*i]),
                     p_chanselect = &geom_pts_chan,
                     from = i, to = i);
    EMerr_hndlr (!(1&stat_OM&msg_loc),*msg,EMS_E_Fail,ret_end);
 
  } /* for (i = 0; i < 2; i++) */

  BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
  length = BSdistptpt(&rc, &pts[0], &pts[3]);
  EMerr_hndlr (length < lentol, *msg, EMS_I_Degenerate, ret_end);
 
  stat_OM = om$send (msg = message GRlinear.GRputpolyline (&msg_loc,
                     md_env, &post_info, &polyline, &newid),
                     targetid = my_id);
  EMerr_hndlr (!(1&stat_OM&msg_loc),*msg,EMS_E_Fail, ret_end);

  GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
  GR_NOTIFY_LISTENERS(msg, &stat_OM, GR_GEOM_MODIFIED);

ret_end:
  EMWRAPUP(*msg, stat_OM, "SKline.SKrecompute_yourself");
  return (stat_OM);
}

method GRrevparm (IGRlong *msg; struct GRmd_env *md_env)
{
  IGRint 		i, inx[2];
  OMuint  		count;
  IGRlong 		stat_OM, msg_loc;
  OM_S_CHANSELECT 	chan_to_defpts, chan_to_geom;
  OM_S_OBJECT_LINKAGE 	ptobjs[2];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Invoke the default implementation
   */

  stat_OM = om$send (mode = OM_e_wrt_parent, msg = message SKline.GRrevparm 
             (&msg_loc, md_env), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Reverse the connection to def-pts from the geometry side. The
   * def-pts should continue to look up to the geometry at the same index.
   */

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  count = 0;  
  om$get_channel_objects (object = me, p_chanselect = &chan_to_defpts,
   count = &count, size = 2, list = ptobjs);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

  for (i=0; i<2; i++)
  {
    OMuint index;
    
    om$get_index (objid_c = ptobjs[i].S_objid, p_chanselect = &chan_to_defpts,
                  objid = my_id, indexaddr = &index);
    inx[i] = index;
  }   

  om$send (msg = message Root.wild_disconnect (chan_to_defpts),
           targetid = my_id);

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  for (i=0; i<2; i++)
    om$send (msg = message Root.connect (chan_to_defpts, inx[i],
                   ptobjs[i].S_objid, OM_Gw_current_OS, chan_to_geom, 0),
             targetid = my_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKline.GRrevparm");
  return (stat_OM);
}

end implementation SKline;
