/*

Name
  SKequal.SKinit

Abstract
  Initialize an equality constraint.
  
Synopsis

Description
    This is the placement method for equality between line segments defined
    by points. The number of points input must be 3 or 4. If three, then the
    assumption is that the first point is repeated to define the segments
    in the following manner: pt1-pt2 and pt1-pt3. If four points then:
    pt1-pt2 and pt3-pt4.

Return Value

Notes

Index

Keywords
  constraint, equality
  
History
  04/26/93 : Rajiv Agrawal : Added SK_OPT_NO_CREATE_EXPR to the valid options list.
                             This is needed so that a self-equal constraint from the
                             arc does not create expressions.
  09/14/93 : Rajiv Agrawal : Added SK_OPT_NO_CREATE_EXPR when the pt-pt constraint is
                             created so that nobody creates useless expressions.

 */

class implementation SKequal;

#include "OMmacros.h"
#include "EMSopt.h"

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern OMuword OPP_SKptpt_class_id;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids; 
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  IGRboolean 		found;
  IGRushort 		loc_opts, valid_options;
  IGRint 		i, j;
  OMuint 		num_cnstrs, num_vars;
  IGRlong 		stat_OM, msg_loc;
  GRclassid 		cnstrclass;
  GRspacenum 		dumos;
  GRobjid 		ptvars[2][2], ptpt_cnstrs[2], cnstrid;
  OM_S_CHANSELECT 	chan_to_cnstrs, chan_to_vars, chan_to_super;
  OM_S_OBJECT_LINKAGE 	ptlist[2];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (num_pts < 3 || num_pts > 4, *msg, EMS_E_InvalidCase, ret_end);
  
  /*
   * If the number of points input is 3, then the four logical points
   * are construed.
   */

  if (num_pts == 3)
    {
    ptvars[FIRST][FIRST] = pt_ids[0];
    ptvars[FIRST][SECOND] = pt_ids[1];
    ptvars[SECOND][FIRST] = pt_ids[0];
    ptvars[SECOND][SECOND] = pt_ids[2];
    }
  else
    OM_BLOCK_MOVE (pt_ids, ptvars, 4 * sizeof (GRobjid));

  /*
   * Create (or use) the pt-pt constraint between the points defining
   * the "line-segment".
   */

  EMmake_chanselect (SKvariable_to_constraints, &chan_to_cnstrs);
  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);

  valid_options = SK_OPT_MARK_AS_USERADD | SK_OPT_MARK_AS_NEWADD;
  loc_opts = options & valid_options;
  for (i=FIRST; i<=SECOND; i++)
    {
    /*
     * Find the point-to-point constraint that may have been constructed
     * between the two points of this "segment". If none found then
     * construct one.
     */

    num_cnstrs = 0;
    om$get_channel_count (p_chanselect = &chan_to_cnstrs,
     objid = ptvars[i][FIRST], count = &num_cnstrs);

    found = FALSE;
    for (j=0; j<num_cnstrs; j++)
      {
      om$get_objid_at_index (objid = ptvars[i][FIRST],
       p_chanselect = &chan_to_cnstrs, index = j,
       objidaddr = &cnstrid, osnumaddr = &dumos);

      om$get_classid (objid = cnstrid, p_classid = &cnstrclass);

      if (cnstrclass == OPP_SKptpt_class_id)
        {
        num_vars = 0;
        om$get_channel_objects (objid = cnstrid, p_chanselect = &chan_to_vars,
        size = 2, count = &num_vars, list = ptlist);
        EMerr_hndlr (num_vars != 2, *msg, EMS_E_InvalidCase, ret_end);

        if (ptlist[FIRST].S_objid == ptvars[i][SECOND] ||
            ptlist[SECOND].S_objid == ptvars[i][SECOND])
          {
          ptpt_cnstrs[i] = cnstrid;
          found = TRUE;
          om$send (msg = message SKconstraint.SKchgprops 
                         (&msg_loc, EMS_O_OFF, SK_NEWADD),
                   targetid = cnstrid);
          break;
          }
        }
      }
    
    if (!found)
      {
      stat_OM = om$construct (classid = OPP_SKptpt_class_id,
                 p_objid = &ptpt_cnstrs[i],
                 msg = message SKconstraint.SKinit (&msg_loc, 
                 (loc_opts | SK_OPT_NO_MGR_CONNECT | SK_OPT_NO_CREATE_EXPR) 
                 & ~SK_OPT_CREATE_GEOMETRY,
                 md_env, 2, ptvars[i], SK_NOVALUE, NULL, NULL));
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }    
  
  /*
   * Connect the point-to-point constraints as my variables and the
   * this constraint becomes a super constraint, owning constraints
   * as variables.
   */

  stat_OM = om$send (msg = message SKconstraint.SKorder_points (&msg_loc,
             NULL, 2, ptpt_cnstrs, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_super);
  for (i=FIRST; i<=SECOND; i++)
    {
    stat_OM  = om$send (msg = message Root.connect (chan_to_vars,
                MAXINT, ptpt_cnstrs[i], OM_Gw_current_OS, chan_to_super,
                MAXINT), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

  /*
   * Invoke the default implementation of this method to do the regular
   * things, like establish connections to the manager and create
   * geometric handles.
   */

  stat_OM = om$send (msg = message SKequal.SKinit (&msg_loc,
             options | SK_OPT_NO_CONNECT_PTS,
             md_env, num_pts, pt_ids, cnstr_props, geom_handle, moreinfo),
             mode = OM_e_wrt_parent, targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKequal.SKinit");
  return (stat_OM);
}

end implementation SKequal;
