class implementation SKcompcurve;

#include <alloca.h>

#define FIRST  0

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from SKmgr import SKget_xymat;

method SKcreate_ptvars (IGRlong *msg; IGRushort opts;
                        IGRshort *mattyp; IGRdouble *mat;
                        IGRshort *to_xy_mattyp; IGRdouble *to_xy_mat;
                        GRobjid *skmgr;
                        IGRint *num_ptvars; GRobjid **ptvars)
{
  IGRboolean is_closed;
  IGRshort loc_xy_mattyp;
  IGRint inx, prev_num_ptvars, curr_num_ptvars;
  OMuint  num_comps;
  IGRlong stat_OM, msg_loc;
  IGRmatrix loc_xy_mat;
  GRobjid loc_skmgr, *loc_ptvars;
  OM_S_OBJECT_LINKAGE *complist;
  OM_S_CHANSELECT chan_to_comps;
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  loc_ptvars = NULL;

  /*
   * Obtain the sketch manager
   */

  if (!skmgr)
    {
    stat_OM = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc,
               &loc_skmgr), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    } 
  else
    loc_skmgr = *skmgr;

  /*
   * Obtain the XYZ-to-XY matrix that would take world-geometry (XYZ) and
   * transform it to local geometry (XY).
   */

  if (! (to_xy_mat || to_xy_mattyp))
    {
    stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
               SK_OPT_GET_XYZ_TO_XY, mattyp, mat, &loc_xy_mattyp, loc_xy_mat),
               targetid = *skmgr);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    {
    loc_xy_mattyp = *to_xy_mattyp;
    OM_BLOCK_MOVE (to_xy_mat, loc_xy_mat, sizeof (IGRmatrix));
    }

  /*
   * To every component geometry in this composite, send the create-ptvars
   * message indicating that the end of the geometry must not be processed.
   * The first point of the next component is attched as the last point
   * of the previous component. In the last component, the processing
   * differs based on whether this is an open or a closed curve.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  num_comps = 0;
  om$get_channel_count (object = me,
   p_chanselect = &chan_to_comps, count = &num_comps);

  if (num_comps)
    {
    complist = (OM_p_OBJECT_LINKAGE) alloca (num_comps *
                sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!complist, *msg, EMS_E_NoStackMemory, ret_end);

    om$get_channel_objects (object = me,
     p_chanselect = &chan_to_comps, count = &num_comps, size = num_comps,
     list = complist);

    is_closed = opts & SK_PROCSKGR_CLOSED;
    opts = SK_PROCSKGR_FULLXFORM;
    prev_num_ptvars = curr_num_ptvars = 0;

    for (inx=0; inx<num_comps; inx++)
      {
      if (inx == num_comps-1 && !is_closed)
        opts |= SK_PROCSKGR_PROCEND;

      prev_num_ptvars = curr_num_ptvars;
      stat_OM = om$send (msg = message SKgeometry.SKcreate_ptvars (&msg_loc,
                 opts, mattyp, mat, &loc_xy_mattyp, loc_xy_mat, &loc_skmgr,
                 &curr_num_ptvars, &loc_ptvars),
                 targetid = complist[inx].S_objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      if (inx > FIRST)
        {
        stat_OM = om$send (msg = message SKgeometry.SKconnect_to_pt (&msg_loc,
                   NULL, loc_ptvars[prev_num_ptvars], 0, MAXINT),
                   targetid = complist[inx-1].S_objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
 
    if (num_comps > 1 && is_closed)
      {
      stat_OM = om$send (msg = message SKgeometry.SKconnect_to_pt (&msg_loc,
                 NULL, loc_ptvars[FIRST], 0, MAXINT),
                 targetid = complist[num_comps-1].S_objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  /*
   * Return the output arguments
   */

  if (ptvars)
    {
    *ptvars = loc_ptvars;
    loc_ptvars = NULL;
    }

  if (num_ptvars)
    *num_ptvars = curr_num_ptvars;
  
ret_end:
  if (loc_ptvars) 
    om$dealloc (ptr = loc_ptvars);

  EMWRAPUP (*msg, stat_OM, "SKcompcurve.SKcreate_ptvars");
  return (stat_OM);
}

end implementation SKcompcurve;

