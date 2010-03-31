/*

Name

Abstract
  Methods to implement Undo machinery in Profiles

Synopsis

Description
    The following two methods implement the capability to undo a profile
    one level back. The items stored in the VLA of the SKmgr are:
    a) old dimension values, followed by a NULL_OBJID.
    b) old variable values, followed by a NULL_OBJID.
    c) the newly added geometric constraints, followed by a NULL_OBJID.

Return Value

Notes

Index

Keywords

History
  10/22/92 : Rajiv Agrawal : Added code to update the dimension text (in DEFER mode)
                     after the expression value is set back to the old one.
  01/31/93 : Rajiv Agrawal : Switch the SK_NEWADD field for all the constraints after a save
                     is done.
  02/08/93 : Rajiv Agrawal : Use the SK_UPDATE_NOSAVESTATE do determine if the old dimension
                     value should be removed from the save state in SKundo_dimval.
                     If the option is set, then the old value is not removed (useful
                     for no-solution cases).
  01/20/94 : Rajiv Agrawal : In SKundo_dimval check if there are any parents of the expression
                     that are being modified.  (TR119415612)
 */

class implementation SKmgr;

#include <math.h>
#include <stdio.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DIglob.h" 
#include "DIprims.h"
#include "bserr.h"
#include "bsparameters.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "dimdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define THIRD  2

extern GRclassid OPP_SKexplicit_class_id;

from SKvariable 	import SKputvar, SKgetvarlist;
from SKconstraint 	import SKchgprops;
from SKexplicit 	import SKputval;
from DMroot		import set_dim_state;

method SKsaveolddim ( long *msg; unsigned short opts; double oldval; GRobjid dimobj )
{
  int              inx, total;
  long             msg_loc, stat_OM;
  struct SKvarinfo *varinfo;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the property bit indicates that a state was just saved, it implies
   * that this modification to the dimension value is following the previous
   * recompute. In this case, the old dimension information is re-initialized.
   */

  if (ME.SKmgr->props & SK_MGR_STATE_SAVED)
  {
    inx = 0;
    varinfo = ME.SKmgr->oldvars;
    while (varinfo[inx].varobj != NULL_OBJID)
      inx++;

    if (inx)
      om$send (msg = message SKmgr.SKundo_dimval ( &msg_loc, SK_UPDATE_DONOTPOST ), 
         targetid = my_id);

    ME.SKmgr->props &= ~SK_MGR_STATE_SAVED;
  }

  /*
   * Add the input old dimension information to the list. To do this, first
   * determine the current total length of the VLA (by looking for the
   * three NULL_OBJID markers).
   */

  total = 0;
  varinfo = ME.SKmgr->oldvars;
  for (inx=FIRST; inx<=THIRD; inx++)
  {
    while (varinfo[total].varobj != NULL_OBJID)
      total++;
    total++;
  }

  if (om$dimension_of ( varray = ME.SKmgr->oldvars ) < total+1)
    om$vla_set_dimension ( varray = ME.SKmgr->oldvars, size = total + 1 );
  varinfo = ME.SKmgr->oldvars;

  OM_BLOCK_MOVE (varinfo, &varinfo[SECOND], total * sizeof (struct SKvarinfo));
  varinfo[FIRST].varobj = dimobj;
  varinfo[FIRST].var[FIRST] = oldval;
  
  /*
   * The old value is not acurate if we are reacting to a change value from 
   * a dimension.
   */
  SKget_last_dim ( OM_Gw_current_OS, varinfo[FIRST].varobj, &varinfo[FIRST].var[FIRST] );

  EMWRAPUP ( *msg, stat_OM, "SKmgr.SKsaveolddim" );
  
  return stat_OM;
}


method SKundo_dimval ( long *msg; unsigned short opts )
{
  int              i, j, inx, total, count, mode;
  long             msg_loc, stat_OM;
  struct SKvarinfo *varinfo;
  struct GRid	   dimid;

  *msg = EMS_I_Useless;
  stat_OM = OM_S_SUCCESS;

  nd$mod_batch (request = ND_GET, p_ret_mode = &mode);

  varinfo = ME.SKmgr->oldvars;

  /*
   * Put back the old values of the dimensions (expressions). If the expression has
   * any parents, then we skip the SKputval to preserve associativity.
   */
  inx = 0;
  while (varinfo [inx].varobj != NULL_OBJID)
  {
    *msg = EMS_S_Success;

    if (!(opts & SK_UPDATE_DONOTPOST))
    {
      stat_OM = om$send ( msg = message NDnode.NDget_objects ( 
                                ND_ROOT, 0, 0, 0, 0, OM_K_MAXINT, &count ),
                          targetid = varinfo [inx].varobj );
      EMerr_hndlr (!stat_OM, stat_OM, OM_E_ABORT, ret_end);
      if (!count) 
      {
        stat_OM = om$send ( msg = message SKexplicit.SKputval ( 
                                  &msg_loc, NULL, varinfo [inx].var [FIRST], NULL ), 
                            targetid = varinfo [inx].varobj );
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, OM_E_ABORT, ret_end);
      }
      
      /*
       * Send an update to the owned dimension in case the user was in DELAY mode.
       */
      
      if (mode == ND_DEFER)
      {
        stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc,
                                 NULL, &dimid, 1, &count, 0, OM_K_MAXINT),
                           targetid = varinfo[inx].varobj);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, OM_E_ABORT, ret_end);
        stat_OM = om$send (msg = message DMroot.set_dim_state (BIT_OR, DIM_TEXT_NEEDS_UPDATE),
                           targetid = dimid.objid, targetos = dimid.osnum);
        EMerr_hndlr (!stat_OM, stat_OM, OM_E_ABORT, ret_end);
      }
    }
    inx++;
  }

  /*
   * Remove these dimension values from the state information (unless inhibited)
   */
  if (inx && !(opts & SK_UPDATE_NOSAVESTATE))
  {
    total = 1;
    j = inx + 1;
    for (i = SECOND; i <= THIRD; i++)
    {
      while (varinfo [j++].varobj != NULL_OBJID)
        total++;
      total++;
    }

    OM_BLOCK_MOVE ( &varinfo [inx], varinfo, total * sizeof ( struct SKvarinfo ) );
  }

ret_end:
  return stat_OM;
}


method SKsavestate ( long *msg; unsigned short opts; struct SKsolvevars *newvars )
{
  short               blksize;
  int                 i, inx, size, num_old_dimvals, num_newdef_vars, num_newhndl_constrs;
  long                msg_loc, stat_OM;
  double              tol, *ptr1, *ptr2;
  struct SKsolvevars  *locvars1, *locvars2, *curvars;
  struct SKvarinfo    *varinfo;
  struct SKconstrinfo *newhndl_constrs;
  void                SKmerge_vars ();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * We no longer need to remember old dimension values (see SKexplicit.SKputval)
   */
  SKforget_dims ();
  
  curvars = NULL;
  newhndl_constrs = NULL;

  /*
   * If the property bit indicates that this message is being sent 
   * soon after a previous save state, then old dimension values are
   * blown away. If not then these are untouched by this method.
   */

  varinfo = ME.SKmgr->oldvars;
  num_old_dimvals = 0;
  while (varinfo[num_old_dimvals].varobj != NULL_OBJID)
    num_old_dimvals++;
  if (ME.SKmgr->props & SK_MGR_STATE_SAVED && num_old_dimvals)
  {
    size = om$dimension_of (varray = ME.SKmgr->oldvars);
    OM_BLOCK_MOVE (&varinfo[num_old_dimvals], varinfo,
        (size - num_old_dimvals) * sizeof (struct SKvarinfo));
    num_old_dimvals = 0;
  }

  /*
   * Compare the old variables with the new ones. Store the old state of 
   * the ones that have changed
   */
  stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
                           SK_GETVR_COMPRESSED, &curvars, NULL, NULL),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (newvars)
  {
    SKmerge_vars (newvars);

    num_newdef_vars = 0;
    locvars1 = newvars;
    while (locvars1)
    {
      num_newdef_vars++;
      locvars1 = locvars1->next;
    }

    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tol);
    locvars1 = newvars;
    for (i=0; i<num_newdef_vars; i++)
    {
      locvars2 = curvars;
      while (locvars2)
      {
        if (locvars2->varobj == locvars1->varobj)
        {
          if (locvars1->props & VAR_X &&
              locvars1->props & VAR_Y)
          {
            ptr1 = locvars1->var;
            ptr2 = locvars2->var;
            if (sqrt (EM2ddistptpts (ptr1, ptr2)) <= tol)
            {
              SKremovevar (locvars2, &curvars);
              om$dealloc (ptr = locvars2);
            }
          }
          else if (locvars1->props & VAR_FIRSTDIM ||
              locvars1->props & VAR_SECONDDIM)
          {
            inx = locvars1->props & VAR_FIRSTDIM ? FIRST : SECOND;
            if (fabs (locvars1->var[inx] -
                locvars2->var[inx]) <= tol)
            {
              SKremovevar (locvars2, &curvars);
              om$dealloc (ptr = locvars2);
            }
          }
          break;
        }
        locvars2 = locvars2->next;
      }
      locvars1 = locvars1->next;
    }
  }

  num_newdef_vars = 0;
  locvars2 = curvars;
  while (locvars2)
  {
    num_newdef_vars++;
    locvars2 = locvars2->next;
  }

  size = (num_old_dimvals+1) + (num_newdef_vars+1);
  if (om$dimension_of (varray = ME.SKmgr->oldvars) < size)
  {
    stat_OM = om$vla_set_dimension (varray = ME.SKmgr->oldvars, 
        size = size);
    EMomerr_exit (stat_OM, ret_end);
  }
  varinfo = &ME.SKmgr->oldvars[num_old_dimvals+1];

  blksize = 2 * sizeof (double);
  locvars2 = curvars;
  for (i=0; i<num_newdef_vars; i++)
  {
    OM_BLOCK_MOVE (locvars2->var, varinfo[i].var, blksize);
    varinfo[i].varobj = locvars2->varobj;
    locvars2 = locvars2->next;
  }
  varinfo[num_newdef_vars].varobj = NULL_OBJID;

  /*
   * All those geometric constraints that have been added since the last
   * compute (marked as SK_NEWADD) must be stored away too. Incorporate this
   * into the same 'varinfo' array. The 'NEW' flag is then turned
   * off for all these constraints.
   */

  num_newhndl_constrs = 0;
  stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
      SK_GETCN_NEW | SK_GETCN_HNDL | SK_GETCN_IMPLICIT, NULL,
      &num_newhndl_constrs, &newhndl_constrs), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  size = (num_old_dimvals+1) + (num_newdef_vars+1) + (num_newhndl_constrs+1);
  if (om$dimension_of (varray = ME.SKmgr->oldvars) < size)
  {
    stat_OM = om$vla_set_dimension (varray = ME.SKmgr->oldvars, 
        size = size);
    EMomerr_exit (stat_OM, ret_end);
  }
  varinfo = &ME.SKmgr->oldvars[(num_old_dimvals+1) + (num_newdef_vars+1)];

  for (i=0; i<num_newhndl_constrs; i++)
    varinfo[i].varobj = newhndl_constrs[i].constrid;
  varinfo[num_newhndl_constrs].varobj = NULL_OBJID;

  for (i=0; i<num_newhndl_constrs; i++)
  {
     stat_OM = om$send (msg = message SKconstraint.SKchgprops 
                              (&msg_loc, EMS_O_OFF, SK_NEWADD), 
                        targetid = newhndl_constrs[i].constrid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);   
  }

  /*
   * Turn the property in the manager on which records the fact that
   * a state has just been recorded.
   */

  ME.SKmgr->props |= SK_MGR_STATE_SAVED;

ret_end:
  if (curvars)
    SKfreevarlist (curvars, MAXINT);
  if (newhndl_constrs)
    om$dealloc (ptr = newhndl_constrs);

  EMWRAPUP (*msg, stat_OM, "SKmgr.SKsavestate");
  
  return stat_OM;
}


method SKundo ( long *msg; unsigned short opts; struct GRmd_env *md_env )
{
  IGRboolean       dim_action, var_action, constr_action, rtree_upd_flag;
  unsigned short   loc_opts;
  int              inx, num_children, mode;
  long             msg_loc, stat_OM;
  GRobjid          varobj;
  GRclassid        varclass;
  enum GRdpmode    dpmode;
  struct GRid      *children, mgr_id;
  struct SKvarinfo *varinfo;
  IGRboolean       aflag = 0;
  struct GRmd_env  display_env;

  gr$get_module_env(buffer = &display_env);
  aflag = pwIsActivationOn();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  dim_action = FALSE;
  var_action = FALSE;
  constr_action = FALSE;
  rtree_upd_flag = TRUE;

  mgr_id.osnum = OM_Gw_current_OS;
  mgr_id.objid = my_id;


  /*
   * Put back the old values of the dimensions (expressions). Any relationship
   * that these expressions may have had with other expressions is 
   * implicitly terminated. 
   */

  msg_loc = EMS_I_Useless;
  om$send (msg = message SKmgr.SKundo_dimval (&msg_loc, NULL),
           targetid = my_id);

  if (msg_loc == EMS_S_Success)
    dim_action = TRUE;

  /*
   * Remove the new constraints that were added. These are found in the
   * third partition of the block of data for undo.
   */

  varinfo = ME.SKmgr->oldvars;
  inx = 0;

  while (varinfo[inx].varobj != NULL_OBJID)
    inx++;
  inx++;

  while (varinfo[inx].varobj != NULL_OBJID)
    inx++;
  inx++;

  while (varinfo[inx].varobj != NULL_OBJID)
  {
    dpmode = GRbe;
    om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
        aflag?&display_env.md_env.matrix_type:
        &md_env->md_env.matrix_type,
        aflag?display_env.md_env.matrix:
        md_env->md_env.matrix,
        &dpmode,
        aflag?&display_env.md_id:
        &md_env->md_id), 
        targetid = varinfo[inx].varobj);

    om$send (msg = message GRgraphics.GRdelete (&msg_loc,
        md_env), targetid = varinfo[inx].varobj);

    constr_action = TRUE;
    inx++;
  }

  /*
   * Put the old variables back. These may be values of a pseudo-variable,
   * that is, a dimension. These variables occur in the second logical
   * block of data for undo. So get the index of the start of the second
   * block. 
   */

  varinfo = ME.SKmgr->oldvars;
  inx = 0;

  while (varinfo[inx].varobj != NULL_OBJID)
    inx++;
  inx++;

  while (varinfo[inx].varobj != NULL_OBJID)
  {
    varobj = varinfo[inx].varobj;
    if (om$is_objid_valid ( objid = varobj ) == OM_S_SUCCESS)
    {
      om$get_classid (objid = varobj, p_classid = &varclass);
      if (om$is_ancestry_valid (subclassid = varclass,
          superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS)
        om$send (msg = message SKexplicit.SKputval 
                       (&msg_loc, NULL, *varinfo[inx].var, NULL), 
                 targetid = varobj);
      else
        om$send (msg = message SKvariable.SKputvar 
                       (&msg_loc, NULL, NULL, NULL, varinfo[inx].var), 
                 targetid = varobj);
    }

    var_action = TRUE;
    inx++;
  }

  /*
   * The undo action on the entities that drive this profile may record the
   * manager as being OUTOFDATE. Since the entire update of the manager is
   * being taken care of within this method, turn this bit in the manager, off.
   */

  ME.SKmgr->props &= ~SK_MGR_OUTOFDATE;

  /*
   * If old variables were indeed put back, the geometry has to be
   * recomputed. Also the geometric handles that depend on this geometry.
   * Notify the batch manager that this profiles dependendents need to
   * be updated.
   */

  if (var_action)
  {
    /*
     * Recompute the geometry
     */

    loc_opts = SK_UPDATE_ERASE | SK_UPDATE_DRAW;
    om$send (msg = message SKmgr.SKgeom_update 
                   (&msg_loc, loc_opts, NULL, md_env), 
             targetid = my_id);

    /*
     * Recompute the constraints. If the batch mode is immediate, the
     * explicit constraints (dimensions) will get recomputed via the
     * batch mechanism. If the mode is not immediate, then do the update
     * here.
     */

    nd$mod_batch (request = ND_INQ, p_ret_mode = &mode);
    loc_opts = SK_UPDATE_IMPCONSTRS | 
        (mode != ND_IMMEDIATE ? SK_UPDATE_EXPCONSTRS : NULL) |
        SK_UPDATE_ERASE | SK_UPDATE_DRAW;
    om$send (msg = message SKmgr.SKconstr_update 
                   (&msg_loc, loc_opts, NULL, md_env), 
             targetid = my_id);

    /* 
     * Update the rtree for the dimension objects. The new dimension object
     * is to be removed from rtree. This is causing problem when a dimension 
     * is edited to a very high value from its original value and undo profile
     * command leaves both new and old dimension objects in the rtree.
     * The recompute is not cleaning the rtree, because of which a function
     * is called. 

     * Similar fix was made previously for TR# 11921307 (edit dimension value) 
     */

     SKremove_dimobjs_from_rtree( &mgr_id, md_env, rtree_upd_flag);

    /*
     * Notify the graph manager that the sketch's dependents must be
     * updated.
     */

    num_children = 0;
    om$send (msg = message NDnode.NDget_objects (ND_CHILDREN | ND_IN_BUF,
        NULL, 0, &children, 0, MAXINT, &num_children), targetid = my_id);

    nd$wait_batch (type = GR_GEOM_POSTED, 
        l_object = children, nb_obj = num_children);

    nd$mod_batch (request = ND_INQ, p_ret_mode = &mode);
    if (mode == ND_IMMEDIATE)
      nd$exec_batch();
  }

  /*
   * The previous state information must now be cleaned out of the
   * manager. That is, now there will not be a previous state recorded.
   */

  varinfo[0].varobj = NULL_OBJID;
  varinfo[1].varobj = NULL_OBJID;
  varinfo[2].varobj = NULL_OBJID;
  ME.SKmgr->props &= ~SK_MGR_STATE_SAVED;

  /*
   * The profile might need splitting.
   */
  SKsplit_profile ( msg, &mgr_id );

  
  /*
   * If no action whatsoever got taken by this method, return
   * a "no-response" message.
   */

  if (! (dim_action || var_action || constr_action))
    *msg = EMS_I_NoResponse;

  EMWRAPUP (*msg, stat_OM, "SKmgr.SKundo");

  return stat_OM;
}

end implementation SKmgr;
