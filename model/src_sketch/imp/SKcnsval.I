class implementation SKconstraint;

#define BLOCK_SIZE		5

from SKmgr import SKcompute, SKchkcycle;

/*

Name
  SKvalidate

Abstract

Synopsis

Description
    This implementation validates this constraint with respect to other 
    constraints that are part of the same manager. Validation checking
    determines if it conflicts with existing constraints or not. If
    the profile in it's current state is fully constrained, the return
    code EMS_I_FullyConstrained is returned.

Return Value

Notes

Index

Keywords
  constraint,profile

History
  10/12/93 : Rajiv Agrawal : added checks to see if the caller really wants to know
                             conflicting constraints.
  12/09/93 : G M K : EMS_I_Degenerate is checking after SKcompute
  01/19/94 : Rajiv Agrawal : Turn graph decomposition OFF during the SKcompute phase.
  
 */
method SKvalidate (IGRlong *msg; IGRushort opts; 
                   struct GRmd_env *md_env; IGRboolean *is_valid;
                   IGRint *num_conflict_cnstr; GRobjid **conflict_cnstr)
{
  IGRint i, num_maj_cnstr;
  IGRlong msg_loc, stat_OM;
  GRobjid duplicate_cnstr, mgrobj, *maj_cnstr, maj_cnstr_mem[BLOCK_SIZE];
  GRobjid degenid;
  struct GRid conflict_cycle_cnstr;
  struct SKsolvevars *varlist;
  struct SKsolvevars *oversolved_vars;
  extern void SKfreevarlist();
  int save_flag;
  extern int _debug_graph_decompose;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  oversolved_vars = NULL;
  maj_cnstr = NULL;

  *is_valid = TRUE;
  *num_conflict_cnstr = 0;

  /*
   * Check if an identical constraint already exists in the
   * system. If so, the twin is returned as the conflicting constraint.
   */

  stat_OM = om$send (msg = message SKconstraint.SKduplicate 
                           (&msg_loc, NULL, &duplicate_cnstr), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (msg_loc == EMS_I_Found)
  {
    *is_valid = FALSE;

    *num_conflict_cnstr = 1;
    if (conflict_cnstr) 
    {
      *conflict_cnstr = (GRobjid *) om$malloc (size = sizeof (GRobjid));
      EMerr_hndlr (!*conflict_cnstr, *msg, EMS_E_NoDynamicMemory, ret_end);
      *(*conflict_cnstr) = duplicate_cnstr;
    }

    *msg = EMS_I_Redundant;
    goto ret_end;
  }

  /*
   * Check if this sketch manager is in a circular dependency state with
   * any piece in the rest of the world
   */

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  if (opts & SK_UPDATE_CHKCYCLE)
  {
    stat_OM = om$send (msg = message SKmgr.SKchkcycle (&msg_loc, NULL,
                             &conflict_cycle_cnstr), 
                       targetid = mgrobj);
    if (msg_loc == EMS_I_Cycle)
    {
      *is_valid = FALSE;
      *num_conflict_cnstr = 1;

      if (conflict_cnstr) 
      {
        *conflict_cnstr = (GRobjid *) om$malloc (size = sizeof (GRobjid));
        EMerr_hndlr (!*conflict_cnstr, *msg, EMS_E_NoDynamicMemory, ret_end);
        *(*conflict_cnstr) = conflict_cycle_cnstr.objid;
      }
      *msg = msg_loc;
      goto ret_end;
    }
  }

  /*
   * Check the system for redundancies.  Turn the graph decomposition OFF for this
   * stage since it is unnecessary work and could lead to some redundant constraints
   * getting in undetected (TR119415660).
   */

  save_flag = _debug_graph_decompose;
  _debug_graph_decompose = 0;
  stat_OM = om$send (msg = message SKmgr.SKcompute (&msg_loc, 
                           SK_UPDATE_NOSAVESTATE | SK_UPDATE_DONOTPOST,
                           md_env, NULL, NULL, &oversolved_vars, &degenid), 
                     targetid = mgrobj);
  _debug_graph_decompose = save_flag;

  if (EMSerror (stat_OM & msg_loc))
  {
    *is_valid = FALSE;
    *msg = EMS_I_InvalidCase;
    stat_OM = OM_S_SUCCESS;
  }
  else if (msg_loc == EMS_I_NoStackMemory)
  {
    *is_valid = FALSE;
    *msg = msg_loc;
  }
  else if (msg_loc == EMS_I_NoSolution)
  {
    *is_valid = FALSE;
    *msg = msg_loc;
  }
  else if (msg_loc == EMS_I_Degenerate)
  {
    *is_valid = FALSE;
    *msg = msg_loc;
    *num_conflict_cnstr = 1;
    if (conflict_cnstr) 
    {
      *conflict_cnstr = (GRobjid *) om$malloc (size = sizeof (GRobjid));
      EMerr_hndlr (!*conflict_cnstr, *msg, EMS_E_NoDynamicMemory, ret_end);
      **conflict_cnstr = degenid;
    }
  }
  else if (msg_loc == EMS_I_FullyConstrained)
  {
    *is_valid = TRUE;
    *msg = msg_loc;
  }
  else if (msg_loc == EMS_I_Redundant)
  {
    *is_valid = FALSE;
    *msg = EMS_I_Redundant;

    if (conflict_cnstr) 
    {
      varlist = oversolved_vars;
      while (varlist)
      {
        num_maj_cnstr = 0;
        maj_cnstr = maj_cnstr_mem;
        stat_OM = om$send (msg = message SKconstraint.SKgetmajconstrs (&msg_loc,
                   NULL, BLOCK_SIZE, &num_maj_cnstr, &maj_cnstr),
                   targetid = varlist->constrid1);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
        for (i=0; i<num_maj_cnstr; i++)
        {
          if (maj_cnstr[i] != my_id)
          {
            if (! (*num_conflict_cnstr % BLOCK_SIZE))
            {
              if (*conflict_cnstr)
                *conflict_cnstr = (GRobjid *) om$realloc (
                                   ptr = (char *) *conflict_cnstr,
                                   size = (*num_conflict_cnstr + BLOCK_SIZE) *
                                   sizeof (GRobjid));
              else
                *conflict_cnstr = (GRobjid *) om$malloc (size = BLOCK_SIZE *
                                   sizeof (GRobjid));
              EMerr_hndlr (!*conflict_cnstr, *msg, EMS_E_NoDynamicMemory,
               ret_end);
            }
  
            (*conflict_cnstr)[*num_conflict_cnstr] = maj_cnstr[i];
            (*num_conflict_cnstr)++;
          }
        }
  
        if (maj_cnstr && maj_cnstr != maj_cnstr_mem)
        {
          om$dealloc (ptr = maj_cnstr);
          maj_cnstr = NULL;
        }
  
        varlist = varlist->next;
      }
    }
  }

ret_end:
  if (oversolved_vars)
    SKfreevarlist (oversolved_vars, MAXINT);
  if (maj_cnstr && maj_cnstr != maj_cnstr_mem)
    om$dealloc (ptr = maj_cnstr);

  EMWRAPUP (*msg, stat_OM, "SKvalidate");
  return (stat_OM);
}

end implementation SKconstraint;
