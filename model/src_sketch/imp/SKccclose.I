class implementation SKcompcurve;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ECmsg.h"

#define FIRST  0
#define SECOND 1
#define LAST   1

#define HORIZONTAL  0
#define VERTICAL    1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKhorizvert_class_id;

from SKmgr import SKcompute;
from SKconstraint import SKinit, SKgetprops, SKvalidate;
from SKvariable import SKswap;

method SKclose (IGRlong *msg; IGRushort opts;
                struct GRmd_env *md_env;
                IGRint *num_conflict_cnstrs; GRobjid **conflict_cnstr_objs)
{
  IGRboolean val_cnstr;
  IGRushort cnstrprops;
  IGRshort action, props;
  IGRint i, j, inx;
  OMuint count, num_cnstrs, num_vars; 
  IGRlong stat_OM, msg_loc;
  GRobjid endgmids[2], endptids[2], cnstrs[2], cnstr, mgrobj, gmhandle, degenid;
  GRspacenum dumos;
  GRclassid cnstrclass;
  OM_S_CHANSELECT chan_to_comps, chan_to_defpts, chan_to_cnstrs, chan_to_vars;
  OM_S_OBJECT_LINKAGE varlist[2];
  enum GRdpmode disp_mode;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_conflict_cnstrs = 0;
  *conflict_cnstr_objs = NULL;

  /*
   * Obtain the end vg-points for this composite curve
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
   count = &count);
  EMerr_hndlr (count < 2, *msg, EMS_E_InvalidArg, ret_end);

  for (i=FIRST, j=0; i<=LAST; i++, j+=count-1)
    om$get_objid_at_index (object = me, p_chanselect = &chan_to_comps,
                           index = j, objidaddr = &endgmids[i], osnumaddr = &dumos);

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  for (i=FIRST; i<=LAST; i++)
  {
    if (i == LAST)
    {
      count = 0;
      om$get_channel_count (objid = endgmids[i],
                            p_chanselect = &chan_to_defpts, count = &count);
      EMerr_hndlr (count < 2, *msg, EMS_E_InvalidCase, ret_end);
      inx = count - 1;
    }
    else
      inx = FIRST;

    om$get_objid_at_index (objid = endgmids[i], p_chanselect = &chan_to_defpts,
                           index = inx, objidaddr = &endptids[i], osnumaddr = &dumos);
  }

  /*
   * If the two endptids are the same, then the composite is already
   * topologically closed. No further action necessary.
   */
 
  if (!IF_NULL_OBJID (endptids[FIRST]) &&
      endptids[FIRST] == endptids[LAST])
  {
    ME.GRcompcurve->comp_props |= GRIS_PHY_CLOSED;

    *msg = EMS_I_Closed;
    goto ret_end;
  }

  /*
   * Check to see if the points have any horizontal/vertical constraints
   * between them. Whichever does not exist, introduce that and recompute.
   * Any conflicts imply that first some constraints need to be freed 
   * for closure to occur.
   */

  EMmake_chanselect (SKvariable_to_constraints, &chan_to_cnstrs);
  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  for (i=HORIZONTAL; i<=VERTICAL; i++)
  {
    cnstrs[i] = NULL_OBJID;

    num_cnstrs = 0;
    om$get_channel_count (objid = endptids[FIRST],
     p_chanselect = &chan_to_cnstrs, count = &num_cnstrs);

    for (j=0; j<num_cnstrs; j++)
    {
      om$get_objid_at_index (objid = endptids[FIRST],
       p_chanselect = &chan_to_cnstrs, index = j,
       objidaddr = &cnstr, osnumaddr = &dumos);

      om$get_classid (objid = cnstr, p_classid = &cnstrclass);
      if (om$is_ancestry_valid (subclassid = cnstrclass,
           superclassid = OPP_SKhorizvert_class_id) == OM_S_SUCCESS)
      {
        num_vars = 0;
        om$get_channel_objects (objid = cnstr, p_chanselect = &chan_to_vars,
         count = &num_vars, size = 2, list = varlist);
        EMerr_hndlr (num_vars != 2, *msg, EMS_E_InvalidCase, ret_end);

        if (endptids[SECOND] != varlist[FIRST].S_objid &&
            endptids[SECOND] != varlist[SECOND].S_objid)
          continue;

        cnstrprops = NULL;
        om$send (msg = message SKconstraint.SKgetprops (&msg_loc, &cnstrprops),
         targetid = cnstr);

        if (i == HORIZONTAL ? cnstrprops & SK_HORIZONTAL : 
                              !(cnstrprops & SK_HORIZONTAL))
          cnstrs[i] = cnstr;
      }
    }
  }

  for (i=HORIZONTAL; i<=VERTICAL; i++)
  {
    if (cnstrs[i] == NULL_OBJID)
    {
      if (i == HORIZONTAL)
        cnstrprops = SK_HORIZONTAL;
      else
        cnstrprops = NULL;
    
      stat_OM = om$construct (classid = OPP_SKhorizvert_class_id,
                 msg = message SKconstraint.SKinit (&msg_loc, SK_OPT_CREATE_GEOMETRY,
                 md_env, 2, endptids, cnstrprops, &gmhandle, NULL),
                 p_objid = &cnstrs[i]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      
      action = 0;
      props = GRIS_DISPLAYABLE;
      stat_OM = om$send (msg = message GRgraphics.GRchgprops (&msg_loc, &action, &props),
                         targetid = gmhandle);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = om$send (msg = message SKconstraint.SKvalidate (&msg_loc,
                               NULL, md_env, &val_cnstr, num_conflict_cnstrs,
                               conflict_cnstr_objs), 
                         targetid = cnstrs[i]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      if (!val_cnstr)
      {
        om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
                 targetid = cnstrs[i]);

        *msg = EMS_I_Redundant;
        goto ret_end;
      }
    }
    else
    {
      /*
       * If a horiz or vert constraint already exists, then we must make it
       * invisible.
       */
      
      disp_mode = GRbe ;
      stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                         &md_env->md_env.matrix_type, md_env->md_env.matrix,
                         &disp_mode, &md_env->md_id),
                         targetid = cnstrs[i] );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      om$get_objid_at_index (objid = cnstrs[i], p_chanselect = &chan_to_comps,
                             index = 0, objidaddr = &gmhandle,
                             osnumaddr = &dumos );              
      action = 0;
      props = GRIS_DISPLAYABLE;
      stat_OM = om$send (msg = message GRgraphics.GRchgprops (&msg_loc, &action, &props),
                         targetid = gmhandle);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    }
  }  

  /*
   * The profile must be recomputed with the above constraints (if any)
   * in place.
   */

  if (!IF_NULL_OBJID (cnstrs[FIRST]) ||
      !IF_NULL_OBJID (cnstrs[SECOND]))
  {
    stat_OM = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc, &mgrobj),
                       targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase,
     ret_end);

    stat_OM = om$send (msg = message SKmgr.SKcompute (&msg_loc, 
                             SK_UPDATE_NOSAVESTATE | SK_UPDATE_ERASE | SK_UPDATE_DRAW |
                             SK_UPDATE_IMPCONSTRS | SK_UPDATE_EXPCONSTRS,
                             md_env, NULL, NULL, NULL, &degenid), 
                       targetid = mgrobj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc) || msg_loc == EMS_I_NoSolution,
                 *msg, EMS_E_InvalidCase, ret_end);
    if (msg_loc == EMS_I_Degenerate)
    {
      *msg = msg_loc;
      ex$message (msgnumb = EMS_S_DegenerateGeometry);
      disp_mode = GRhd;
      stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                               &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                               &disp_mode, &md_env->md_id), 
                         targetid = degenid);
      goto ret_end;
    }

    for (i=FIRST; i<=SECOND; i++)
      if (!IF_NULL_OBJID (cnstrs[i]))
        om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
                 targetid = cnstrs[i]);
  }

  /*
   * Swap in the first point in place of the last one. The last point
   * is deleted.
   */

  stat_OM = om$send (msg = message SKvariable.SKswap (&msg_loc,
                           SK_UPDATE_DELETEOLD, endptids[FIRST]), 
                     targetid = endptids[LAST]);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  ME.GRcompcurve->comp_props |= GRIS_PHY_CLOSED;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcompcurve.SKclose");
  return (stat_OM);
}

end implementation SKcompcurve;

