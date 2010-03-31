/*
  DESCRIPTION

    Given the Z-vector and the X-vector that a window must have, this function
    transforms a given set of windows. Optionally, a graphics-object that
    must fit wthin this window can be provided and the view-volume is adjusted
    accordingly.

    Also included in this file, temporarily is the function to obtain a reduced
    range of a surface if it has been trimmed considerably (more than 85%).

  HISTORY

    SS  :  09/24/90  :  Creation.
 Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

class implementation GRvg;

#include "EMS.h"
#include "ems_m_inc.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "ma.h"
#include "matypemx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "ma3protmx.h"
#include "bspartofsf.h"
#include "bsfreesf.h"
#include "bscrossp.h"
#include "bsbx2.h"
#include "bsallocsf.h"

#define X 0
#define Y 1
#define Z 2

#define XMIN 0
#define YMIN 1
#define ZMIN 2
#define XMAX 3
#define YMAX 4
#define ZMAX 5

#define INC_FACTOR  0.1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSsubbs_class_id;

from EMSloopset import EMgetrange;

IGRlong EMsetwinornt (msg, num_win, win, origpt, xvec, zvec, grobj)
IGRlong *msg;
IGRint num_win;
struct GRid *win;
IGRpoint origpt;
IGRvector xvec, zvec;
struct GRlc_info *grobj;
{
  IGRboolean in_world;
  IGRshort xform_mattyp, four=4;
  IGRint i, inx;
  IGRlong one=1, stat_OM, msg_loc, dum;
  IGRdouble xinc, yinc, z_near, z_far, z_width, active_z;
  IGRpoint pt, xpt2, ypt2, origin, vw_origin;
  IGRvector yvec;
  IGRmatrix vw_rotation, xform_mat;
  GRobjid grobjid;
  GRspacenum grobjnum;
  GRrange grobj_range, vw_volume;
  GRclassid grobj_class;
  struct var_list list_var[5];
  IGRlong EMgetredrange();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  origin[X] = origin[Y] = origin[Z] = 0.0;

  BScrossp (&msg_loc, zvec, xvec, yvec);
  for (i=0; i<3; i++)
    {
    xpt2[i] = origpt[i] + xvec[i];
    ypt2[i] = origpt[i] + yvec[i];
    }
  MA3protmx (&msg_loc, origpt, xpt2, ypt2, vw_rotation);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (grobj)
    {
    MAmulmx (&msg_loc, &four, &four, &four, vw_rotation,
     grobj->module_info.md_env.matrix, xform_mat);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    MAtypemx (&msg_loc, xform_mat, &xform_mattyp);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    grobjid = grobj->located_obj.objid;
    grobjnum = grobj->located_obj.osnum;
    om$get_classid (objid = grobjid, osnum = grobjnum,
     p_classid = &grobj_class);

    stat_OM = om$is_ancestry_valid (subclassid = grobj_class,
               superclassid = OPP_EMSsubbs_class_id);
    if (stat_OM == OM_S_SUCCESS)
      {
      stat_OM = EMgetredrange (&msg_loc, &xform_mattyp, xform_mat,
                 &grobj->located_obj, grobj_range);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {
      in_world = TRUE;
      stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc, 
                 &xform_mattyp, xform_mat, &in_world, grobj_range),
                 targetid = grobj->located_obj.objid, 
                 targetos = grobj->located_obj.osnum, 
                 senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    xinc = INC_FACTOR * (grobj_range[XMAX] - grobj_range[XMIN]);
    yinc = INC_FACTOR * (grobj_range[YMAX] - grobj_range[YMIN]);
    grobj_range[XMIN] -= xinc;
    grobj_range[YMIN] -= yinc;
    grobj_range[XMAX] += xinc;
    grobj_range[YMAX] += yinc;

    MAptsxform (&msg_loc, &one, vw_rotation, origpt, pt);
    active_z = pt[Z];
    }

  for (i=0; i<num_win; i++)
    {
    if (grobj)
      {
      /*
       * If a graphic object has been specified, obtain the existing 
       * view-volume so that the z-depths can be preserved.
       */

      list_var[0].var = VW_VOLUME;
      list_var[0].var_ptr = (char *) vw_volume;
      list_var[0].num_bytes = sizeof (GRrange);
      list_var[0].bytes_returned = &dum;

      list_var[1].var = END_PARAM;
      list_var[1].var_ptr = NULL;
      list_var[1].num_bytes = 0;
      list_var[1].bytes_returned = NULL;

      stat_OM = dp$inq_set_gragad (msg = &msg_loc, osnum = win[i].osnum, 
                 gragad_objid = win[i].objid, which_error = &dum,
                 var_list = list_var);
      EMomerr_exit (stat_OM, ret_end);
      }

    /*
     * Compute and set the new window info
     */

    inx = 0;
    list_var[inx].var = VIEW_ORIGIN;
    list_var[inx].var_ptr = (char *) origin;
    list_var[inx].num_bytes = 3 * sizeof (IGRdouble);
    list_var[inx++].bytes_returned = &dum;

    list_var[inx].var = VIEW_ROTATION;
    list_var[inx].var_ptr = (char *) vw_rotation;
    list_var[inx].num_bytes = sizeof (IGRmatrix);
    list_var[inx++].bytes_returned = &dum;

    list_var[inx].var = ACT_Z;
    list_var[inx].var_ptr = (char *) &active_z;
    list_var[inx].num_bytes = sizeof (IGRdouble);
    list_var[inx++].bytes_returned = &dum;

    if (grobj)
      {
      /*
       * If a graphic object was available, the window is fitted to the 
       * objects range. The z-depths are preserved.
       */

      z_near = vw_volume[ZMIN];
      z_far = vw_volume[ZMAX];
      z_width = (z_far - z_near) / 2.0;
      OM_BLOCK_MOVE (grobj_range, vw_volume, sizeof (GRrange));
      vw_volume[ZMIN] = active_z - z_width;
      vw_volume[ZMAX] = active_z + z_width;

      list_var[inx].var = VW_VOLUME;
      list_var[inx].var_ptr = (char *) vw_volume;
      list_var[inx].num_bytes = sizeof (GRrange);
      list_var[inx++].bytes_returned = &dum;
      }

    list_var[inx].var = END_PARAM;
    list_var[inx].var_ptr = NULL;
    list_var[inx].num_bytes = 0;
    list_var[inx++].bytes_returned = NULL;

    stat_OM = dp$inq_set_gragad (msg = &msg_loc, inq0_set1 = 1,
               calc_info = 1, update = 1,
               osnum = win[i].osnum, gragad_objid = win[i].objid,
               which_error = &dum, var_list = list_var);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMsetwinornt");
  return (stat_OM);
}


#define U 0
#define V 1

#define UMIN 0
#define UMAX 1
#define VMIN 2
#define VMAX 3

#define REDUCE_FACTOR 0.85

IGRlong EMgetredrange (msg, mattyp, mat, sfid, range)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct GRid *sfid;
GRrange range;
{
  IGRboolean in_world;
  IGRint i;
  IGRlong totnumpoles,msg_loc, stat_OM;
  IGRdouble uvrange[4], mid_pars[2], u_side, v_side;
  struct IGRbsp_surface *partsf, *sf;
  OM_S_CHANSELECT chan_to_loopset;
  extern IGRlong EMgetabsg();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  partsf = NULL;
 
  om$make_chanselect (channame = "EMSsubbs.to_loopset", 
   p_chanselect = &chan_to_loopset);

  uvrange[UMIN] = 0.0;
  uvrange[UMAX] = 1.0;
  uvrange[VMIN] = 0.0;
  uvrange[VMAX] = 1.0;
  stat_OM = om$send (msg = message EMSloopset.EMgetrange (&msg_loc, uvrange),
             p_chanselect = &chan_to_loopset, targetos = sfid->osnum,
             senderid = sfid->objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

/*
 * Adjust the range so that it is within parametric space
 */
  for (i=0;i<4;i++)
  {
   if (uvrange[i] < 0.0)
    uvrange[i] = 0.0;
   else if (uvrange[i] > 1.0)
    uvrange[i] = 1.0;
  }


  u_side = uvrange[UMAX] - uvrange[UMIN];
  v_side = uvrange[VMAX] - uvrange[VMIN];
  if (u_side * v_side < REDUCE_FACTOR)
    {
    stat_OM = EMgetabsg (&msg_loc, mattyp, mat, sfid->osnum, sfid->objid, 
               &sf);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    BSallocsf (sf->u_order, sf->v_order, sf->u_num_poles + 2 * sf->u_order - 1,
     sf->v_num_poles + 2 * sf->v_order - 1, sf->rational, NULL,
     &partsf, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

    mid_pars[U] = (uvrange[UMAX] - uvrange[UMIN]) / 2.0;
    mid_pars[V] = (uvrange[VMAX] - uvrange[VMIN]) / 2.0;
    BSpartofsf (sf, &uvrange[UMIN], mid_pars, &uvrange[VMIN], 2,
     partsf, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

    totnumpoles = partsf->u_num_poles * partsf->v_num_poles;
    BSbx2 (&msg_loc, &totnumpoles, (IGRpoint *)partsf->poles,
     partsf->rational ? partsf->weights : NULL, &range[0], &range[3]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
    }
  else
    {
    in_world = TRUE;
    stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc, 
               mattyp, mat, &in_world, range), targetid = sfid->objid, 
               targetos = sfid->osnum, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  if (partsf)
    BSfreesf (&msg_loc, partsf);
  EMWRAPUP (*msg, stat_OM, "EMgetredrange");
  return (stat_OM);
}

end implementation GRvg;
