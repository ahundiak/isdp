/*

Name
  SKcompute

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords
  profile

History
   RA   : 10/27/92 :  Keep a backup of the old values of the profile variables.  
                      In case the profile degenerates, post the old values back.
  10/05/93 : Rajiv Agrawal : Added degeneracy checking with the solution vector.
  12/09/93 : G M K : check degeneracy code moved 
  01/10/94 : Model Integration : Fixed opp error by moving import statements
                                 to the top of the file.
 */

class implementation SKmgr;

%safe
static int     sm_validate_pervcnstr();
%endsafe

from SKgeometry   import SKcheck_degeneracy;
from EMSpervcnstr import EMvalidate_direction;

method SKcompute ( long *msg; unsigned short opts; struct GRmd_env *md_env;
                   struct SKsolvevars **nosolution_vars,
                                      **undersolved_vars, 
                                      **oversolved_vars;
                   GRobjid *degenid)
{
  int                i, num_undersolved;
  long               msg_loc, stat_OM;
  struct SKsolvepath solvepath;
  struct SKsolvevars *prev_varlist, *varlist;
  struct SKsolvevars *loc_solved_vars, *loc_nosolution_vars;
  struct SKsolvevars *loc_undersolved_vars, *loc_oversolved_vars;
  OM_S_CHANSELECT    to_components;
  extern long        SKsolve ();

  /* Due to the way plane normal were computed changed from version 2.0 to
     2.1, some of the perpendicular vector constraints were rendered
     invalid. Correct this by validating them. Once validated these constraints
     will be marked as such and not validated subsequently.

     The validation is done through the EMSdpb wake up method also (see
     src_dpb/imp/EMdpbi.I). The action here is required to catch the placement
     of macros, because macro libraries do not go through the dpb machinery
     when attatched.

     SM 3/2/93
  */
  (void) sm_validate_pervcnstr(msg, md_env, my_id);


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (nosolution_vars)
    *nosolution_vars = NULL;
  if (undersolved_vars)
    *undersolved_vars = NULL;
  if (oversolved_vars)
    *oversolved_vars = NULL;

  loc_solved_vars = NULL;
  loc_nosolution_vars = NULL;
  loc_undersolved_vars = NULL;
  num_undersolved = 0;
  loc_oversolved_vars = NULL;
  solvepath.constrs = NULL;
  solvepath.action = NULL;

  /*
   * Perform the analysis on the constraints and the variables within
   * this system, determining the solution path, any under-constrained
   * variables and the overconstrained variables. If overconstrainedness
   * is found, terminate with appropriate return code. If underconstrainedness
   * found, treat these variables as ground in the subsequent solution
   * process. But keep track of these variables (via "num_undersolved")
   * for later output.
   */

  stat_OM = om$send ( msg = message SKmgr.SKanalyze (&msg_loc, NULL,
      loc_solved_vars, &loc_undersolved_vars, &loc_oversolved_vars,
      &solvepath), targetid = my_id );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  EMerr_hndlr ( msg_loc == EMS_I_NoStackMemory, *msg, msg_loc, ret_end );

  if (msg_loc == EMS_I_Redundant)
  {
    if (oversolved_vars)
    {
      *oversolved_vars = loc_oversolved_vars;
      loc_oversolved_vars = NULL;
    }
    *msg = msg_loc;
    goto ret_end;
  }

  else if (msg_loc == EMS_I_UnderConstrained)
  {
    varlist = loc_undersolved_vars;
    while (varlist)
    {
      num_undersolved++;
      varlist = varlist->next;
    }
    loc_solved_vars = loc_undersolved_vars;
    loc_undersolved_vars = NULL;
    *msg = msg_loc;
  }

  /*
   * Knowing the solution path, solve the system. An oversolved can still
   * occur. In addition, a no-solution situation might exist. In either of
   * these cases terminate processing with the appropriate return code and
   * also format the error output (oversolved, nosolution vars). If all
   * of the under-constrainedness has not been detected in the analysis
   * phase, some of it may be detected here. Keep track of these 
   * underconstrained variables.
   */
  stat_OM = SKsolve ( &msg_loc, NULL, &solvepath,
                      OM_Gw_current_OS, &loc_solved_vars, &loc_nosolution_vars, 
                      &loc_undersolved_vars, &loc_oversolved_vars );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  if (msg_loc == EMS_I_Redundant || msg_loc == EMS_I_Conflicting)
  {
    if (oversolved_vars)
    {
      *oversolved_vars = loc_oversolved_vars;
      loc_oversolved_vars = NULL;
    }
    *msg = EMS_I_Redundant;
    goto ret_end;
  }
  else if (msg_loc == EMS_I_NoSolution)
  {
    if (nosolution_vars)
    {
      *nosolution_vars = loc_nosolution_vars;
      loc_nosolution_vars = NULL;
    }
    *msg = msg_loc;
    goto ret_end;
  }
  else if (msg_loc == EMS_I_UnderConstrained || num_undersolved)
  {
    prev_varlist = varlist = loc_undersolved_vars;
    while (varlist)
    {
      num_undersolved++;
      prev_varlist = varlist;
      varlist = varlist->next;
    }
    if (prev_varlist)
      prev_varlist->next = loc_solved_vars;
    else
      loc_undersolved_vars = loc_solved_vars;
    *msg = msg_loc;
  }
  else if (msg_loc == EMS_S_Success)
    *msg = EMS_I_FullyConstrained;

  /* 
   * If the previous state of the variables has to be saved, do so
   * by saving the current state of this object.
   */
  if (!(opts & SK_UPDATE_NOSAVESTATE))
  {
    stat_OM = om$send (msg = message SKmgr.SKsavestate (&msg_loc, NULL,
                             loc_solved_vars), 
                       targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  
  /*
   * check degeneracy of geometry
   */
  if (degenid) 
  {
    *degenid = NULL_OBJID;
    EMmake_chanselect ( GRcmpowner_to_components, &to_components );
    stat_OM = om$send ( msg = message SKgeometry.SKcheck_degeneracy 
                              (&msg_loc, NULL, md_env, loc_solved_vars, degenid),
                        p_chanselect = &to_components);
    if (!IF_NULL_OBJID(*degenid))
    {
      *msg = EMS_I_Degenerate;
      goto ret_end;      
    }
  }

  /*
   * The solved variables are posted into the system and the relevant
   * pieces of the system updated. After this point the sketch cannot
   * be out of date.
   */
  if (!(opts & SK_UPDATE_DONOTPOST))
  {

    stat_OM = om$send ( msg = message SKmgr.SKvar_update ( &msg_loc, 
                              SK_UPDATE_PSEUDOVAL, loc_solved_vars), 
                        targetid = my_id );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

    if (!(opts & SK_UPDATE_GEOMNOPOST))
    {
      stat_OM = om$send (msg = message SKmgr.SKgeom_update ( &msg_loc, 
          opts, NULL, md_env), targetid = my_id );
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
    }

    if (!(opts & SK_UPDATE_CNSTRNOPOST))
    {
      stat_OM = om$send ( msg = message SKmgr.SKconstr_update ( &msg_loc, opts,
          NULL, md_env), targetid = my_id );
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
    }

    ME.SKmgr->props &= ~SK_MGR_OUTOFDATE;
  }

  /*
   * Any undersolved variables are now output
   */
  if (num_undersolved)
  {
    if (undersolved_vars)
    {
      *undersolved_vars = varlist = loc_undersolved_vars;
      loc_undersolved_vars = NULL;
      for (i = 0; i < num_undersolved-1; i++)
        varlist = varlist->next;
      loc_solved_vars = varlist->next;
      varlist->next = NULL;
    }
    *msg = EMS_I_UnderConstrained;
  }

ret_end:
  if (loc_solved_vars)
  {
    /* if loc_solved_vars is in the undersolved list, we don't free */
    for (varlist = loc_undersolved_vars; varlist; varlist = varlist->next)
      if (varlist == loc_solved_vars)
        break;
    if (!varlist)
      SKfreevarlist ( loc_solved_vars, MAXINT );
  }
  if (loc_nosolution_vars)
    SKfreevarlist ( loc_nosolution_vars, MAXINT );
  if (loc_undersolved_vars)
    SKfreevarlist ( loc_undersolved_vars, MAXINT );
  if (loc_oversolved_vars)
    SKfreevarlist ( loc_oversolved_vars, MAXINT );
  if (solvepath.constrs)
    om$dealloc ( ptr = solvepath.constrs );
  if (solvepath.action)
    om$dealloc ( ptr = solvepath.action );

  EMWRAPUP ( *msg, stat_OM, "SKmgr.SKcompute" );

  return stat_OM;
}



static IGRint sm_validate_pervcnstr(EMmsg, md_env, mgrid)
IGRlong *EMmsg;
struct GRmd_env *md_env;
GRobjid mgrid;
{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_comps, to_children;
 OMuint			count = 0;
 GRobjid		compid;
 GRspacenum		compos;
 IGRint			i;

 EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 EMmake_chanselect (NDchildren_children, &to_children);

 sts = om$get_channel_count(objid = mgrid, p_chanselect = &to_comps, 
       count = &count);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<count; i++)
  {
   sts = om$get_objid_at_index(objid = mgrid, p_chanselect = &to_comps, 
         index = i, objidaddr = &compid, osnumaddr = &compos);
   if(!(1&sts)) continue;

   /* Send the EMSpervcnstr.EMvalidate_direction message to the children
      of the compcurve. I am not checking for a particular class of objects
      on either to_comps or to_child channels but ignoring all errors.
   */
   (void) om$send(msg = message EMSpervcnstr.EMvalidate_direction
         (EMmsg, md_env), senderid = compid, p_chanselect = &to_children);
   *EMmsg = EMS_S_Success;
  }

wrapup:
return(sts);
}
                  
end implementation SKmgr;

