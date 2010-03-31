/*

Name
  SKsolve

Abstract

Synopsis
  long               *msg		return code			   OUT
  unsigned short     opts		options				   IN 
  struct SKsolvepath *solvepath	        an ordered list of constraints 
                                          to evaluate (see SKmgranalyze)   IN
  GRspacenum         os		        object Space of the profile	   IN 
  struct SKsolvevars **solvedvars       the solved variables		   OUT
  struct SKsolvevars **nosolution_vars  the variables we can't solve	   OUT
  struct SKsolvevars **undersolved_vars the variables without enough
                                          constraints			   OUT
  struct SKsolvevars **oversolved_vars  constraints that form a 
                                        redundant/conflicting set.         OUT

Description
    This function serves as the solution engine for a system of constraints
    and unknowns. It takes as input a solution path which consists mainly
    of an array of constraints in the sequence that they must be solved.
    Variables whose solution values are already known (grounds) are passed in.
    To each constraint corresponds a variable that will be output when
    that particular constraint is evaluated. It might be required to evaluate
    a subset of this array of constraints simultaneously (using say, the
    Jacobian technique). In this case there is no one-to-one correspondence
    between the constraint and the variable, but instead the set of variables
    corresponding to the set of constraints are output at the same time.
    If there are more variables than constraints, the corresponding constraint
    id is NULL.

    Those variables that had no solution or those that are underconstrained
    or those that are overconstrained are output. The overconstrained
    variables have associated with them the constraint that caused this
    redundancy.

Return Value
    The message return code will be one of the following:

    EMS_S_Success
     All went well. 

    EMS_I_Redundant
     There is an overconstraint in the system and the overconstraint is
     being returned in the output argument (if passed as non-NULL).

    EMS_I_UnderConstrained
     Variable(s) are underconstrained in the system and these are being
     returned in the output argument (if passed as non-NULL). The system
     has been solved regardless.

    EMS_E_InvalidCase
     A contradictory situation exists in the system.

    EMS_E_Fail
     Some failure

Notes

Index

Keywords

History
  08/14/90 : Siki : Creation
  01/07/92 : HGB : Test for tolerance
  10/05/93 : Rajiv Agrawal : Removed test for tolerance since it is now done in
                             SKsimulsolve_jacob.

 */

class implementation SKconstraint;


#define EMomerr_exit(sts, label)  if (EMSerror (sts)) goto label;
#define FIRST  0
#define SECOND 1

from SKexplicit import SKevalpseudoeqn, SKgetval, SKgetname;
from SKvalvar   import SKgetname;
from SKvariable import SKgetvar;

long SKsolve ( long               *msg, 
               unsigned short     opts,
               struct SKsolvepath *solvepath,
               GRspacenum         os,
               struct SKsolvevars **solvedvars,
               struct SKsolvevars **nosolution_vars,
               struct SKsolvevars **undersolved_vars,
               struct SKsolvevars **oversolved_vars
             )
{
  short               exec_type;
  int                 i, inx, next_inx, iter_limit, tot_num_constrs, 
                      num_to_exec, num_simul;
  long                msg_loc, stat_OM;
  double              iter_tol;
  struct SKsolvevars  solvethis;
  struct SKconstrinfo *constrs;
  void                SKgetiterpar();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  SKgetiterpar ( &iter_limit, &iter_tol );

  /*
   * Go through the constraint execution path, evaluating in sequence
   * the unknowns. When a loop is hit in the sequence, it means the
   * constraints within the loop need to be solved in a simultaneous
   * fashion using the Jacobian technique.
   */
  num_to_exec = tot_num_constrs = solvepath->num_constrs;
  constrs = solvepath->constrs;
  inx = 0;
  while (num_to_exec)
  {
    exec_type = solvepath->action [inx];
    if (exec_type == PATH_EVALCONSTR)
    {
      solvethis.varobj = constrs [inx].varsolveid;
      solvethis.props = constrs [inx].vprops;
      if (constrs[inx].cprops & CONSTR_PSEUDO_EQN)
        stat_OM = om$send (msg = message SKexplicit.SKevalpseudoeqn
                                 ( &msg_loc, opts, solvedvars, &solvethis,
                                   oversolved_vars, nosolution_vars ),
                           targetid = constrs[inx].constrid, targetos = os,
                           senderid = NULL_OBJID );
      else
        stat_OM = om$send ( msg = message SKconstraint.SKevaluate 
                                  ( &msg_loc, opts, &solvethis, solvedvars,
                                    nosolution_vars ),
                            targetid = constrs[inx].constrid, targetos = os,
                            senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr ( msg_loc == EMS_I_NoSolution, *msg, msg_loc, ret_end);

      num_to_exec--;
      inx++;
    }
    else if (exec_type == PATH_SIMULCONSTR || exec_type == PATH_OSIMULCONSTR)
    {
      num_simul = 0;
      for (i = inx; i < tot_num_constrs; i++)
        if (solvepath->action [i] == exec_type)
          num_simul++;
        else
          break;
      next_inx = i;

      stat_OM = SKsimulsolve_jacob ( &msg_loc, NULL, num_simul,
                                     &solvepath->constrs [inx], os, 
                                     iter_limit, iter_tol,
                                     solvedvars, undersolved_vars, oversolved_vars,
                                     nosolution_vars ); 
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

      if (msg_loc == EMS_I_NoSolution || msg_loc == EMS_I_Redundant || 
          msg_loc == EMS_I_Conflicting)
      {
        *msg = msg_loc;
        goto ret_end;
      }
      if (msg_loc == EMS_I_UnderConstrained)
        *msg = msg_loc;

      num_to_exec -= num_simul;
      inx = next_inx;
    }
    else
    {
      EMerr_hndlr ( TRUE, *msg, EMS_E_InvalidArg, ret_end );
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKsolve");
  return stat_OM;
}

end implementation SKconstraint;

#if OLD_UNUSED_CODE_NEEDS_TO_BE_RESURRECTED
#include "DIdef.h"
  IGRboolean          do_jacob;
  char                varname [DI_PATH_MAX];
  unsigned short      jacob_opts, varprops;
      do_jacob = TRUE;
      /* we loop on SKsimulsove until we are happy with the tolerance of each
         constraint we have been dealing with */
      for (iter_count = 0; (iter_count < iter_limit) && do_jacob; iter_count += 10)
      {
        /* Create the list of unsolved variables.*/
        for (j = 0; j < tot_num_constrs; j++)
        {
          /* any solved is not unsolved (sic) */
          if (SKvarlistinx ( *solvedvars, solvepath->constrs [j].varsolveid,
                solvepath->constrs [j].vprops, NULL, NULL ))
            continue;
          
          varprops = solvepath->constrs [j].vprops;
          varname [0] = NULL;
          if (varprops & VAR_PSEUDO_VAL)
          {
            stat_OM = om$send ( msg = message SKexplicit.SKgetval ( &msg_loc2, var ),
                targetid = solvepath->constrs [j].varsolveid, 
                targetos = os,
                senderid = NULL_OBJID );
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc2 ), *msg, EMS_E_Fail, ret_end );
      
            stat_OM = om$send ( msg = message SKexplicit.SKgetname 
                ( &msg_loc2, SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, varname ),
                targetid = solvepath->constrs [j].varsolveid, 
                targetos = os,
                senderid = NULL_OBJID );
            EMerr_hndlr (EMSerror ( stat_OM & msg_loc2 ), *msg, EMS_E_Fail, ret_end );
          }
          else
          {
            stat_OM = om$send ( msg = message SKvariable.SKgetvar 
                ( &msg_loc2, NULL, NULL, NULL, var ),
                targetid = solvepath->constrs [j].varsolveid,
                targetos = os,
                senderid = NULL_OBJID );
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc2 ), *msg, EMS_E_Fail, ret_end );
            
            if (varprops & VAR_VAL)
            {
              stat_OM = om$send ( msg = message SKvalvar.SKgetname 
                  ( &msg_loc2, SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, varname ),
                  targetid = solvepath->constrs [j].varsolveid, 
                  targetos = os,
                  senderid = NULL_OBJID );
              EMerr_hndlr ( EMSerror ( stat_OM & msg_loc2 ), *msg, EMS_E_Fail, ret_end );
            }
          }
      
          SKaddvarlist ( &msg_loc2, NULL, &unsolvedvars, varprops, 
              solvepath->constrs [j].varsolveid, 
              solvepath->constrs [j].constrid, solvepath->constrs [j].constrid,
              varprops & VAR_FIRSTDIM ? var : &var [SECOND], varname );
          EMerr_hndlr ( EMSerror ( msg_loc2 ), *msg, EMS_E_Fail, ret_end );
        }
       /* see if each constraint is within the virtual zero */
        for (j = inx; j < inx + num_simul; j++)
          if (solvepath->constrs [j].constrid != NULL_OBJID)
          {
            jacob_opts = SK_JACOB_ACCURACY;
            if (solvepath->constrs[j].cprops & CONSTR_PSEUDO_VAR)
              jacob_opts |= SK_JACOB_PSEUDO_VAR;
            if (solvepath->constrs[j].cprops & CONSTR_PSEUDO_EQN)
              jacob_opts |= SK_JACOB_PSEUDO_EQN;
            if (solvepath->constrs[j].cprops & CONSTR_GRND_Y)
              jacob_opts |= SK_JACOB_GROUND_SECDIM;
  
            stat_OM = om$send ( msg = message SKconstraint.SKmakejacobian
                ( &msg_loc2, jacob_opts, *solvedvars, unsolvedvars, NULL, NULL ),
                targetid =  solvepath->constrs [j].constrid,
                targetos = os,
                senderid = NULL_OBJID );
            if (stat_OM & 1)
              if (msg_loc2 == EMS_I_OutOfBounds)
                break;
            EMerr_hndlr ( EMSerror (stat_OM & msg_loc2), *msg, EMS_E_Fail, ret_end );
          }
        
        /* all the constraints passed the test */
        if (j == inx + num_simul)
          do_jacob = FALSE;
        
        /* if not, then divide the iteration tolerance by a 100 and keep going */
        if (do_jacob)
          iter_tol *= 0.01;

        /* free the list of unsolved variables */
        if (unsolvedvars)
        {
          SKfreevarlist ( unsolvedvars, MAXINT );
          unsolvedvars = NULL;
        }
      }
        /* in case of error (or the ghost profile), there is no need to get more accuracy */
        if ((msg_loc == EMS_I_NoSolution) || (msg_loc == EMS_I_Degenerate) ||
            (msg_loc == EMS_I_Redundant) || (msg_loc == EMS_I_Conflicting) ||
            (opts & SK_UPDATE_DISPLAY_GHOST))
        {
          do_jacob = FALSE;
          continue;
        }
#endif
